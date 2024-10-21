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
                Insignia_Cat_ID: badgeObj.categoryId,
                meta: badgeObj.meta,
                // optional
                foto: badgeObj.image,
            },
        ])
        .select()
    
    error ? console.log(error) : console.log(`Badge created: ${JSON.stringify(data)}`)
    
    return { data, error };
}

async function get(columns = '*') {
    const { data, error } = await supabase
        .from('Insignias')
        .select(columns)
    
    error ? console.log(error) : console.log(`Badges found: ${JSON.stringify(data)}`)
    
    return { data, error };
}

async function getById(id, columns = '*') {
    const { data, error } = await supabase
        .from('Insignias')
        .select(columns)
        .eq('Insignia_ID', id)
    
    error ? console.log(error) : console.log(`Badge found: ${JSON.stringify(data)}`)
    
    return { data, error };
}

async function update(badgeId, badgeObj) {
    // Add the current timestamp to the badgeObj
    const currentTimestamp = new Date().toISOString();
    badgeObj.fechaModificacion = currentTimestamp;

    const { data, error } = await supabase
        .from('Insignias')
        .update(badgeObj)
        .eq('Insignia_ID', badgeId)
        .select();

    if (error) {
        console.log(error);
    } else {
        console.log(`Badge updated: ${JSON.stringify(data)}`);
    }

    return { data, error };
}

async function deleteById(badgeId) {
    const { data, error } = await supabase
        .from('Insignias')
        .delete()
        .eq('Insignia_ID', badgeId)
        .select()

    error ? console.log(error) : console.log(`Badge deleted: ${JSON.stringify(data)}`)
    
    return { data, error };
}

export default {
    create,
    get,
    getById,
    update,
    deleteById,
};