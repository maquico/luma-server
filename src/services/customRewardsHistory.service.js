import supabaseConfig from "../configs/supabase.js";

const { supabase } = supabaseConfig;

async function getByUser(userId) {
    const { data, error } = await supabase
        .from('Historial_Recompensas')
        .select("cantidadComprada, Recompensas(Recompensa_ID, Proyecto_ID, Icono_ID, nombre, descripcion, precio, cantidad, limite, totalCompras)")
        .eq('Usuario_ID', userId);

    if (error) {
        console.log(error);
        return { data: null, error };
    } else {
        console.log(`Bought custom rewards found for user ID ${userId}: ${data.length}`);
        // Flatten the nested Recompensas objects and merge with cantidadComprada
        const flattenedData = data.map(item => ({
            ...item.Recompensas,
            cantidadComprada: item.cantidadComprada
        }));
        return { data: flattenedData, error: null };
    }
}

export default {
    getByUser,
};