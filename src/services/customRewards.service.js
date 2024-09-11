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

export default {
    create,
    eliminate,
    update,
    getRecompensas,
};