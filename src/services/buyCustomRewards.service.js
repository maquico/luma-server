import supabaseConfig from "../configs/supabase.js";
const { supabase } = supabaseConfig;

async function buyCustomReward(userId, rewardId) {
    let errorObject = { message: '', status: 200 };
    let content = null;

    // 1. Obtener los datos de la recompensa
    const { data: rewardData, error: rewardError } = await supabase
        .from('Recompensas')
        .select('precio, limite, totalCompras, cantidad, Proyecto_ID')
        .eq('Recompensa_ID', rewardId)
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
    buyCustomReward,
};
