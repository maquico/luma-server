import supabaseConfig from "../configs/supabase.js";
import customRewardsHistoryService from "./customRewardsHistory.service.js";
import projectMemberService from "./projectMember.service.js";
const { supabase } = supabaseConfig;

async function createAdmin(projectId, iconoId, nombre, descripcion, precio, cantidad, limite) {
    const { data, error } = await supabase
        .from('Recompensas')
        .insert([
            {
                Proyecto_ID: projectId,
                Icono_ID: iconoId,
                nombre: nombre,
                descripcion: descripcion,
                precio: precio,
                cantidad: cantidad,
                limite: limite,
            },
        ])
        .select()
    return { data, error };
}


async function create(projectId, iconoId, nombre, descripcion, precio, cantidad, limite, userId) {
    // Verificar si el usuario tiene el rol de líder
    const { data: userRoleData, error: userRoleError } = await supabase
        .from('Miembro_Proyecto')
        .select('Rol_ID')
        .eq('Proyecto_ID', projectId)
        .eq('Usuario_ID', userId)
        .single();

    if (userRoleError || userRoleData?.Rol_ID !== 2) {
        return { error: userRoleError || 'El usuario no tiene permisos de líder para crear recompensas.' };
    }

    // Insertar la recompensa si el usuario es líder
    const { data, error } = await supabase
        .from('Recompensas')
        .insert([
            {
                Proyecto_ID: projectId,
                Icono_ID: iconoId,
                nombre: nombre,
                descripcion: descripcion,
                precio: precio,
                cantidad: cantidad,
                limite: limite,
            },
        ])
        .select();

    return { data, error };
}

async function eliminate(rewardId, requestUserId) {
    // get project id from reward id
    const { data: rewardData, error: rewardError } = await getById(rewardId, 'Proyecto_ID');
    if (rewardError) {
        console.error('Error al obtener la recompensa:', rewardError);
        return { data: null, error: rewardError };
    }

    const projectId = rewardData[0].Proyecto_ID;
    const { data: isLeader, error: leaderError } = await projectMemberService.checkMemberRole(requestUserId, projectId, "Lider");
    if (leaderError) {
        console.error('Error al verificar si el usuario es líder:', leaderError);
        return { data: null, error: leaderError };
    }

    if (!isLeader) {
        const errorObject = { message: 'El usuario no tiene permisos para editar el proyecto.', status: 403 };
        return { data: null, error: errorObject };
    }
    const { data, error } = await supabase
        .from('Recompensas')
        .update({
            eliminado: true
        })
        .eq('Recompensa_ID', rewardId)
        .eq('eliminado', false)
        .select()
    return { data, error };
}

async function update(iconoId, nombre, descripcion, precio, cantidad, limite, rewardId, requestUserId) {
    // get project id from reward id
    const { data: rewardData, error: rewardError } = await getById(rewardId, 'Proyecto_ID');
    if (rewardError) {
        console.error('Error al obtener la recompensa:', rewardError);
        return { data: null, error: rewardError };
    }

    const projectId = rewardData[0].Proyecto_ID;
    const { data: isLeader, error: leaderError } = await projectMemberService.checkMemberRole(requestUserId, projectId, "Lider");
    if (leaderError) {
        console.error('Error al verificar si el usuario es líder:', leaderError);
        return { data: null, error: leaderError };
    }

    if (!isLeader) {
        const errorObject = { message: 'El usuario no tiene permisos para editar el proyecto.', status: 403 };
        return { data: null, error: errorObject };
    }

    const { data, error } = await supabase
        .from('Recompensas')
        .update({
            Icono_ID: iconoId,
            nombre: nombre,
            descripcion: descripcion,
            precio: precio,
            cantidad: cantidad,
            limite: limite,
        })
        .eq('Recompensa_ID', rewardId)
        .eq('eliminado', false)
        .select()
    return { data, error };
}

async function getRecompensas() {
    const { data, error } = await supabase
        .from('Recompensas')
        .select('*')
        .eq('eliminado', false)
    return { data, error };
}

async function getById(id, columns='*') {
    const { data, error } = await supabase
        .from('Recompensas')
        .select(columns)
        .eq('Recompensa_ID', id)
        .eq('eliminado', false)
    return { data, error };
}

async function getByProject(projectId, columns='*') {
    const { data, error } = await supabase
        .from('Recompensas')
        .select(columns)
        .eq('Proyecto_ID', projectId)
        .eq('eliminado', false)
    return { data, error };
}

async function getByUserShop(userId) {
    let errorObject = { message: '', status: 200 };
    let rewards = null;

    const [
        { data: customRewardsHistory, error: customRewardsHistoryError },
        { data: projectMemberships, error: projectMembershipsError }
    ] = await Promise.all([
        customRewardsHistoryService.getByUser(userId),
        projectMemberService.getByUserId(userId)
    ]);

    if (customRewardsHistoryError) {
        console.log(`Error getting custom rewards history: ${customRewardsHistoryError.message}`);
        errorObject.message = customRewardsHistoryError.message;
        errorObject.status = customRewardsHistoryError.status;
        return { data: rewards, error: errorObject };
    }

    if (projectMembershipsError) {
        console.log(`Error getting project memberships: ${projectMembershipsError.message}`);
        errorObject.message = projectMembershipsError.message;
        errorObject.status = projectMembershipsError.status;
        return { data: rewards, error: errorObject };
    }

    // Get all project IDs the user belongs to
    const projectIds = projectMemberships.map(membership => membership.Proyecto_ID);

    //console.log(projectIds);

    // Fetch all recompensas for each project ID
    const recompensasPromises = projectIds.map(projectId => getByProject(projectId, '*, Iconos(nombre, foto)'));
    const recompensasResults = await Promise.all(recompensasPromises);

    //console.log(recompensasResults);
    // Flatten the recompensas results
    const recompensas = recompensasResults.flatMap(result => result.data);

    //console.log(`Found ${recompensas.length} recompensas for user ID ${userId}`);
    //console.log(recompensas);

    // Map the recompensas with the custom rewards history
    const customRewardsMap = recompensas.map(reward => {
        const customRewardHistory = customRewardsHistory.filter(hist => hist.Recompensa_ID === reward.Recompensa_ID);
        const customRewardBought = customRewardHistory ? customRewardHistory.length: 0;
        const customRewardIsAvailable = customRewardBought < reward.limite && reward.totalCompras < reward.cantidad;
        const customRewardAvailable = reward.cantidad - reward.totalCompras;

        return {
            type: 'custom',
            id: reward.Recompensa_ID,
            name: reward.nombre,
            price: reward.precio,
            available: customRewardIsAvailable,
            totalCreated: reward.cantidad,
            totalAvailable: customRewardAvailable,
            totalBought: customRewardBought,
            totalCapacity: reward.limite,
            metadata: {
                icon: {
                    id: reward.Icono_ID,
                    name: reward.Iconos.nombre,
                    image: reward.Iconos.foto,
                },
                description: reward.descripcion,
                projectId: reward.Proyecto_ID,
            },
        };
    });

    // Return a single list with all the rewards
    rewards = customRewardsMap;
    // console log as json
    //console.log(JSON.stringify(rewards));
    errorObject = null;

    return {
        data: rewards,
        error: errorObject
    };
}

async function buyCustomReward(userId, rewardId) {
    let errorObject = { message: '', status: 200 };
    let content = null;

    // 1. Obtener los datos de la recompensa
    const { data: rewardData, error: rewardError } = await supabase
        .from('Recompensas')
        .select('precio, limite, totalCompras, cantidad, Proyecto_ID')
        .eq('Recompensa_ID', rewardId)
        .eq('eliminado', false)
        .single();

    if (rewardError) {
        console.log(`Error fetching reward: ${rewardError.message}`);
        errorObject.message = rewardError.message;
        errorObject.status = 500;
        return { data: null, error: errorObject };
    }

    const { precio, limite, totalCompras, cantidad, Proyecto_ID } = rewardData;

    // 2. Verificar si la recompensa ha alcanzado el máximo de compras globales
    if (totalCompras >= cantidad) {
        errorObject.message = 'Se ha alcanzado el máximo de recompensas disponibles';
        errorObject.status = 400;
        return { data: null, error: errorObject };
    }

    // 3. Obtener la cantidad de recompensas compradas por el usuario
    const { data: userPurchases, error: purchaseError } = await supabase
        .from('Historial_Recompensas')
        .select('cantidadComprada')
        .eq('Usuario_ID', userId)
        .eq('Recompensa_ID', rewardId);

    if (purchaseError) {
        console.log(`Error fetching user purchases: ${purchaseError.message}`);
        errorObject.message = purchaseError.message;
        errorObject.status = 500;
        return { data: null, error: errorObject };
    }

    const userTotalBought = userPurchases.reduce((acc, curr) => acc + curr.cantidadComprada, 0);

    // 4. Verificar si el usuario ya ha alcanzado el límite de recompensas
    if (userTotalBought >= limite) {
        errorObject.message = 'Has alcanzado el límite de compras para esta recompensa';
        errorObject.status = 400;
        return { data: null, error: errorObject };
    }

    // 5. Obtener las gemas del usuario en el proyecto correspondiente
    const { data: projectMembership, error: projectError } = await supabase
        .from('Miembro_Proyecto')
        .select('gemas')
        .eq('Usuario_ID', userId)
        .eq('Proyecto_ID', Proyecto_ID)
        .single();

    if (projectError) {
        console.log(`Error fetching user gems: ${projectError.message}`);
        errorObject.message = projectError.message;
        errorObject.status = 500;
        return { data: null, error: errorObject };
    }

    const { gemas } = projectMembership;

    // 6. Verificar si el usuario tiene suficientes gemas
    if (gemas < precio) {
        errorObject.message = 'No tienes suficientes gemas para esta recompensa';
        errorObject.status = 400;
        return { data: null, error: errorObject };
    }

    // 7. Llamar a la función de PostgreSQL para procesar la compra y devolver los datos actualizados
    const { data: updatedData, error: functionError } = await supabase.rpc('buy_with_gems_transaction', {
        p_usuario_id: userId,
        p_recompensa_id: rewardId,
        p_precio: precio,
    });

    if (functionError) {
        console.log(`Error processing reward purchase: ${functionError.message}`);
        errorObject.message = functionError.message;
        errorObject.status = 500;
        return { data: null, error: errorObject };
    }

    // Si todo sale bien, devolver los datos actualizados
    content = {
        message: 'Recompensa personalizada comprada exitosamente',
        updatedData,
    };
    return { data: content, error: null };
}

export default {
    createAdmin,
    create,
    eliminate,
    update,
    getRecompensas,
    getById,
    getByProject,
    getByUserShop,
    buyCustomReward,
};