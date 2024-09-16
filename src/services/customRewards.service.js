import supabaseConfig from "../configs/supabase.js";
import customRewardsHistoryService from "./customRewardsHistory.service.js";
import customRewardsService from "./customRewards.service.js";
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

async function getByUserAndProject(userId, projectId) {
    const continueFunction = true;
    let errorObject = { message: '', status: 200 };
    let rewards = [];

    const [
        { data: customRewardsHistory, error: customRewardsHistoryError },
        { data: customRewards, error: customRewardsError }
      ] = await Promise.all([
        customRewardsHistoryService.getByUserAndProject(userId, projectId),
        getByProject(projectId)
      ]);

    if(customRewardsHistoryError) {
        console.log(`Error getting custom rewards history: ${customRewardsHistoryError.message}`);
        errorObject.message = customRewardsHistoryError.message;
        errorObject.status = customRewardsHistoryError.status;
        continueFunction = false;
    }
    else if(customRewardsError) {
        console.log(`Error getting custom rewards: ${customRewardsError.message}`);
        errorObject.message = customRewardsError.message;
        errorObject.status = customRewardsError.status;
        continueFunction = false;
    }

    if(continueFunction) {

        // map the custom rewards
        const customRewardsMap = customRewards.map(reward => {
            const customRewardHistory = customRewardsHistory.find(customRewardHistory => customRewardHistory.Recompensa_ID === reward.Recompensa_ID);
            const customRewardBought = customRewardHistory ? customRewardHistory.cantidadComprada : 0;
            const customRewardAvailable = customRewardBought < reward.limite && reward.totalCompras < reward.cantidad ? false : true;

            return {
                type: 'custom',
                id: reward.Recompensa_ID,
                name: reward.nombre,
                price: reward.precio,
                available: customRewardAvailable,
                totalAvailable: reward.cantidad,
                totalBought: customRewardBought ,
                totalCapacity: reward.limite,
                metadata: {
                    icon: reward.Icono_ID,
                    description: reward.descripcion,
                },
            };
        });
        
        // Return a single list with all the rewards
        rewards = customRewardsMap;
        // console log as json
        console.log(JSON.stringify(rewards));
        errorObject = null;
    }

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
};