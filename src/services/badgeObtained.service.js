import supabaseConfig from "../configs/supabase.js";

const { supabase } = supabaseConfig;

async function create(badgeObj) {
    console.log("Badge obj: ", badgeObj)
    const { data, error } = await supabase
        .from('Insignia_Conseguida')
        .insert([
            {
                // required
                Usuario_ID: badgeObj.userId,
                Insignia_ID: badgeObj.badgeId
            },
        ])
        .select()
    
    error ? console.log(error) : console.log(`Badge created: ${JSON.stringify(data)}`)
    
    return { data, error };
}

async function get(columns = '*') {
    const { data, error } = await supabase
        .from('Insignia_Conseguida')
        .select(columns)
    
    error ? console.log(error) : console.log(`Badges found: ${JSON.stringify(data)}`)
    
    return { data, error };
}

async function getByUser(id, columns = 'Insignias(Insignia_ID, nombre, descripcion, foto), Usuarios(Usuario_ID, nombre, apellido)') {
    const { data, error } = await supabase
        .from('Insignia_Conseguida')
        .select(columns)
        .eq('Usuario_ID', id)
    
    if (error) {
        console.log(error);
        return { data: null, error };
    }

    console.log(`Badge found: ${JSON.stringify(data)}`)

    if (!data.length) {
        return { data: data, error: null };
    }
    const responseObj = {
        userId: data[0].Usuarios.Usuario_ID,
        userFullName: `${data[0].Usuarios.nombre} ${data[0].Usuarios.apellido}`,
        badges: data.map(badge => {
            return {
                badgeId: badge.Insignia_ID,
                badgeName: badge.Insignias.nombre,
                badgeDescription: badge.Insignias.descripcion,
                badgeImage: badge.Insignias.foto
            }
        })
    }
    
    return { data:responseObj, error };
}

async function getByBadge(id, columns = '*') {
    const { data, error } = await supabase
        .from('Insignia_Conseguida')
        .select(columns)
        .eq('Insignia_ID', id)
    
    error ? console.log(error) : console.log(`Badge found: ${JSON.stringify(data)}`)
    
    return { data, error };
}

async function getByUserAndBadge(userId, badgeId, columns = '*') {
    const { data, error } = await supabase
        .from('Insignia_Conseguida')
        .select(columns)
        .eq('Usuario_ID', userId)
        .eq('Insignia_ID', badgeId)
    
    error ? console.log(error) : console.log(`Badge found: ${JSON.stringify(data)}`)
    
    return { data, error };
}

async function deleteByUserAndBadge(userId, badgeId) {
    const { data, error } = await supabase
        .from('Insignia_Conseguida')
        .delete()
        .eq('Usuario_ID', userId)
        .eq('Insignia_ID', badgeId)
        .select()
    
    error ? console.log(error) : console.log(`Badge deleted: ${JSON.stringify(data)}`)
    
    return { data, error };
}

export default {
    create,
    get,
    getByUser,
    getByBadge,
    getByUserAndBadge,
    deleteByUserAndBadge,
};