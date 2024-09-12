import supabaseConfig from "../configs/supabase.js"; 
const { supabase } = supabaseConfig; 

async function create(nombre, descripcion) {
    const { data, error } = await supabase
        .from('Proyectos')
        .insert([
            {
                nombre: nombre,
                descripcion: descripcion
            },
        ])
        .select()
    return { data, error };
}

async function getProyectos() {
    const { data, error } = await supabase
        .from('Proyectos')
        .select('*')
    return { data, error };
}

async function getByUser(userId) {
    // Primero, obtenemos los IDs de los proyectos en los que el usuario está involucrado
    const { data: proyectoIds, error: errorIds } = await supabase
        .from('Miembro_Proyecto')
        .select('Proyecto_ID')
        .eq('Usuario_ID', userId);

    if (errorIds) {
        console.error('Error al obtener IDs de proyectos:', errorIds);
        return { Proyectos: null, error: errorIds };
    }

    // Si no hay proyectos asociados, devolvemos un array vacío
    if (!proyectoIds || proyectoIds.length === 0) {
        return { Proyectos: [], error: null };
    }

    // Extraemos los IDs en un array simple
    const ids = proyectoIds.map(item => item.Proyecto_ID);

    // Luego, usamos esos IDs para obtener los proyectos
    const { data: Proyectos, error } = await supabase
        .from('Proyectos')
        .select('*')
        .in('Proyecto_ID', ids);

    if (error) {
        console.error('Error al obtener proyectos:', error);
    } else {
        console.log('Proyectos del usuario:', Proyectos);
    }

    return { Proyectos, error };
}

export default {
    create,
    getProyectos,
    getByUser,
}