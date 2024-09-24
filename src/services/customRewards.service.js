import supabaseConfig from "../configs/supabase.js";
import customRewardsHistoryService from "./customRewardsHistory.service.js";
import projectMemberService from "./projectMember.service.js";
const { supabase } = supabaseConfig;

async function create(projectId, iconoId, nombre, descripcion, precio, cantidad, limite) {
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

async function eliminate(id) {
    const { error } = await supabase
        .from('Recompensas')
        .delete()
        .eq('Recompensa_ID', id)
    return { error };
}

async function update(iconoId, nombre, descripcion, precio, cantidad, limite, id) {
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
        .eq('Recompensa_ID', id)
        .select()
    return { data, error };
}

async function getRecompensas() {
    const { data, error } = await supabase
        .from('Recompensas')
        .select('*')
    return { data, error };
}

async function getById(id) {
    const { data, error } = await supabase
        .from('Recompensas')
        .select('*')
        .eq('Recompensa_ID', id)
    return { data, error };
}

async function getByProject(projectId) {
    const { data, error } = await supabase
        .from('Recompensas')
        .select('*')
        .eq('Proyecto_ID', projectId)
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
    const recompensasPromises = projectIds.map(projectId => getByProject(projectId));
    const recompensasResults = await Promise.all(recompensasPromises);

    //console.log(recompensasResults);
    // Flatten the recompensas results
    const recompensas = recompensasResults.flatMap(result => result.data);

    //console.log(`Found ${recompensas.length} recompensas for user ID ${userId}`);
    //console.log(recompensas);

    // Map the recompensas with the custom rewards history
    const customRewardsMap = recompensas.map(reward => {
        const customRewardHistory = customRewardsHistory.find(hist => hist.Recompensa_ID === reward.Recompensa_ID);
        const customRewardBought = customRewardHistory ? customRewardHistory.cantidadComprada : 0;
        const customRewardAvailable = customRewardBought < reward.limite && reward.totalCompras < reward.cantidad;

        return {
            type: 'custom',
            id: reward.Recompensa_ID,
            name: reward.nombre,
            price: reward.precio,
            available: customRewardAvailable,
            totalAvailable: reward.cantidad,
            totalBought: customRewardBought,
            totalCapacity: reward.limite,
            metadata: {
                icon: reward.Icono_ID,
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

export default {
    create,
    eliminate,
    update,
    getRecompensas,
    getById,
    getByProject,
    getByUserShop,
};