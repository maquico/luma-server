import supabaseConfig from "../configs/supabase.js";

const { supabase } = supabaseConfig;

async function create(badgeObj) {
    const { data, error } = await supabase
        .from('Insignias')
        .insert([
            {
                // required
                nombre: badgeObj.name,
                descripcion: badgeObj.description,
                // optional
                imagen: badgeObj.image,
                puntos: badgeObj.points,
            },
        ])
        .select()   
    return { data, error };
}