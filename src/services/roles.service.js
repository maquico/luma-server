import supabaseConfig from "../configs/supabase.js";
const { supabase } = supabaseConfig;

async function create(nombre, descripcion) {
    const { data, error } = await supabase
        .from('Roles')
        .insert([
            { nombre: nombre, descripcion: descripcion }
        ])
        .select()
    return { data, error };
}

async function eliminate(id) {
    const { error } = await supabase
        .from('Roles')
        .delete()
        .eq('Rol_ID', id)
    return { error };
}

async function update(nombre, descripcion, id) {
    const { data, error } = await supabase
        .from('Roles')
        .update({
            nombre: nombre,
            descripcion: descripcion
        })
        .eq('Rol_ID', id)
        .select()
    return { data, error };
}

async function getRoles() {
    const { data, error } = await supabase
        .from('Roles')
        .select('*')
    return { data, error };
}

async function getById(id) {
    const { data, error } = await supabase
        .from('Roles')
        .select('*')
        .eq('Rol_ID', id)
    return { data, error };
}

export default {
    create,
    eliminate,
    update,
    getRoles,
    getById
};