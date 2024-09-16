import supabaseConfig from "../configs/supabase.js";

const { supabase } = supabaseConfig;

async function getByUserAndProject(userId, projectId) {
    const { data, error } = await supabase
        .from('Historial_Recompensas')
        .select("*, Recompensas(*)")
        .eq('Usuario_ID', userId)
        .eq('Recompensas.Proyecto_ID', projectId);

    if (error) {
        console.log(error);
    } else {
        console.log(`Bought custom rewards found for user ID ${userId} and project ID ${projectId}: ${data.length}`);
        // delete the elements with Recompensas = null and merge Recompensas attributes
        for (let i = 0; i < data.length; i++) {
            if (data[i].Recompensas == null) {
                data.splice(i, 1);
                i--;
            } else {
                // Merge Recompensas attributes into the parent object
                data[i] = { ...data[i], ...data[i].Recompensas };
                delete data[i].Recompensas;
            }
        }
    }
    return { data, error };
}

export default {
    getByUserAndProject,
};