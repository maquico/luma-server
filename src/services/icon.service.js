import supabaseConfig from "../configs/supabase.js";

const { supabase } = supabaseConfig;

async function create(iconObj) {
    const { data, error } = await supabase
        .from('Iconos')
        .insert([
            {
                // required
                nombre: iconObj.name,
                // optional
                foto: iconObj.image,
            },
        ])
        .select()
    
    error ? console.log(error) : console.log(`Icon created: ${JSON.stringify(data)}`)
    
    return { data, error };
}

async function get(columns = '*') {
    const { data, error } = await supabase
        .from('Iconos')
        .select(columns)
    
    error ? console.log(error) : console.log(`Icons found: ${JSON.stringify(data)}`)
    
    return { data, error };
}

async function getById(id, columns = '*') {
    const { data, error } = await supabase
        .from('Iconos')
        .select(columns)
        .eq('Icono_ID', id)
    
    error ? console.log(error) : console.log(`Icon found: ${JSON.stringify(data)}`)
    
    return { data, error };
}

async function update(iconId, iconObj) {
    // Add the current timestamp to the iconObj
    const currentTimestamp = new Date().toISOString();
    iconObj.fechaModificacion = currentTimestamp;

    const { data, error } = await supabase
        .from('Iconos')
        .update(iconObj)
        .eq('Icono_ID', iconId)
        .select();

    if (error) {
        console.log(error);
    } else {
        console.log(`Icon updated: ${JSON.stringify(data)}`);
    }

    return { data, error };
}


export default {
    create,
    get,
    getById,
    update,
};