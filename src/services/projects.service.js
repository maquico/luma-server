import supabaseConfig from "../configs/supabase.js";
const { supabase } = supabaseConfig;

// async function create(nombre, descripcion, userId) {
//     const { data, error } = await supabase
//         .from('Proyectos')
//         .insert([
//             {
//                 nombre: nombre,
//                 descripcion: descripcion,
//                 Usuario_ID: userId
//             },
//         ])
//         .select()
//     return { data, error };
// }

async function create(nombre, descripcion, userId) {
    let project = null;
    let errorObject = { message: '', status: 200 };
    // Llamada a la función almacenada en PostgreSQL
    const { data, error } = await supabase
        .rpc('create_project_with_creator', {
            project_name: nombre,
            project_description: descripcion,
            creator_user_id: userId
        });

    if (error) {
        console.error('Error al crear el proyecto:', error);
        errorObject.message = `INTERNAL DATABASE ERROR CODE: ${error.code}. Message: ${error.message}`;
        errorObject.status = 500;
        return { data: null, error: errorObject };
    }
    else {
        console.log('Proyecto creado:', data[0]);
        project = data[0];
    }
    console.log('Proyecto:', project);
    return { data: project, error: null };
}


async function getProyectos() {
    const { data, error } = await supabase
        .from('Proyectos')
        .select('*')
    return { data, error };
}

async function getById(id) {
    const { data, error } = await supabase
        .from('Proyectos')
        .select('*')
        .eq('Proyecto_ID', id)
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

    // Luego, usamos esos IDs para obtener los proyectos (incluyendo Usuario_ID internamente para identificar al creador)
    const { data: Proyectos, error: errorProyectos } = await supabase
        .from('Proyectos')
        .select('Proyecto_ID, nombre, descripcion, fechaRegistro, Usuario_ID')  // Incluimos Usuario_ID pero no lo devolveremos
        .in('Proyecto_ID', ids);

    if (errorProyectos) {
        console.error('Error al obtener proyectos:', errorProyectos);
        return { Proyectos: null, error: errorProyectos };
    }

    // Iteramos sobre cada proyecto para agregar los miembros y el creador
    for (let proyecto of Proyectos) {
        // Obtener los miembros del proyecto
        const { data: miembrosProyecto, error: errorMiembros } = await supabase
            .from('Miembro_Proyecto')
            .select('Usuario_ID')
            .eq('Proyecto_ID', proyecto.Proyecto_ID);

        if (errorMiembros) {
            console.error('Error al obtener miembros del proyecto:', errorMiembros);
            return { Proyectos: null, error: errorMiembros };
        }

        // Obtener los IDs de todos los miembros (incluido el creador si es parte de Miembro_Proyecto)
        let usuarioIds = miembrosProyecto.map(m => m.Usuario_ID);

        // Agregar Usuario_ID del creador si no está ya en la lista de miembros
        if (proyecto.Usuario_ID && !usuarioIds.includes(proyecto.Usuario_ID)) {
            usuarioIds.push(proyecto.Usuario_ID);
        }

        // Filtrar valores no válidos
        usuarioIds = usuarioIds.filter(id => id !== undefined && id !== null);

        // Obtener los nombres y apellidos de los usuarios
        const { data: usuarios, error: errorUsuarios } = await supabase
            .from('Usuarios')
            .select('Usuario_ID, nombre, apellido')
            .in('Usuario_ID', usuarioIds);

        if (errorUsuarios) {
            console.error('Error al obtener nombres de usuarios:', errorUsuarios);
            return { Proyectos: null, error: errorUsuarios };
        }

        // Encontrar al creador y construir su nombre completo
        const creadorUsuario = usuarios.find(u => u.Usuario_ID === proyecto.Usuario_ID);
        const creador = creadorUsuario ? `${creadorUsuario.nombre} ${creadorUsuario.apellido}` : null;

        // Obtener los nombres completos de los miembros (incluyendo al creador si es parte de los miembros)
        const miembros = usuarios.map(u => `${u.nombre} ${u.apellido}`);

        // Agregar los miembros y el creador al proyecto
        proyecto.members = miembros;
        proyecto.creator = creador;

        // Eliminar Usuario_ID del objeto proyecto antes de devolverlo
        delete proyecto.Usuario_ID;
    }

    // Devolvemos los proyectos con miembros y creador, pero sin Usuario_ID
    return { Proyectos, error: null };
}

// async function getByUser(userId) {
//     // Primero, obtenemos los IDs de los proyectos en los que el usuario está involucrado
//     const { data: proyectoIds, error: errorIds } = await supabase
//         .from('Miembro_Proyecto')
//         .select('Proyecto_ID')
//         .eq('Usuario_ID', userId);

//     if (errorIds) {
//         console.error('Error al obtener IDs de proyectos:', errorIds);
//         return { Proyectos: null, error: errorIds };
//     }

//     // Si no hay proyectos asociados, devolvemos un array vacío
//     if (!proyectoIds || proyectoIds.length === 0) {
//         return { Proyectos: [], error: null };
//     }

//     // Extraemos los IDs en un array simple
//     const ids = proyectoIds.map(item => item.Proyecto_ID);

//     // Luego, usamos esos IDs para obtener los proyectos
//     const { data: Proyectos, error } = await supabase
//         .from('Proyectos')
//         .select('*')
//         .in('Proyecto_ID', ids);

//     if (error) {
//         console.error('Error al obtener proyectos:', error);
//     } else {
//         console.log('Proyectos del usuario:', Proyectos);
//     }

//     return { Proyectos, error };
// }

export default {
    create,
    getProyectos,
    getById,
    getByUser,
}