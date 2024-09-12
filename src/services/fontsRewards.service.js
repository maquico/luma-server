import supabaseConfig from "../configs/supabase.js"; 
const { supabase } = supabaseConfig; 

async function create(nombre, precio) {
    const { data, error } = await supabase
        .from('Fuentes')
        .insert([
            {
                nombre: nombre,
                precio: precio
            },
        ])
        .select()
    return { data, error };
}

async function eliminate(id) {
    const { error } = await supabase
        .from('Fuentes')
        .delete()
        .eq('Fuente_ID', id)
    return { data, error };
}

async function update(nombre, precio, id) {
    const { data, error } = await supabase
        .from('Fuentes')
        .update({ nombre: nombre, precio: precio })
        .eq('Fuente_ID', id)
        .select()
    return { data, error };
}

async function getFuentes() {
    const { data, error } = await supabase
        .from('Fuentes')
        .select('*')
    return { data, error };
}


export default {
    create,
    eliminate,
    update,
    getFuentes,
};