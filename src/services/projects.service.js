import supabase from "../configs/supabase.js";

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

// async function getByUser(userId) {
//     const { data: Proyectos, error } = await supabase
//         .from('Proyectos')
//         .select('*')
//         .in('Proyecto_ID', supabase
//             .from('Miembro_Proyecto')
//             .select('Proyecto_ID')
//             .eq('Usuario_ID', userId)
//         );

//     if (error) {
//         console.error('Error:', error);
//     } else {
//         console.log('Proyectos del usuario:', Proyectos);
//     }
//     return { Proyectos, error };
// }

export default {
    create,
    getProyectos,
}