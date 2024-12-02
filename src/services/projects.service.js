import supabaseConfig from "../configs/supabase.js";
import memberService from './projectMember.service.js';
const { supabase } = supabaseConfig;

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

async function update(nombre, descripcion, projectId, requestUserId) {
    const { data: isLeader, error: leaderError } = await memberService.checkMemberRole(requestUserId, projectId, "Lider");
    if (leaderError) {
        console.error('Error al verificar si el usuario es líder:', leaderError);
        return { data: null, error: leaderError };
    }

    if (!isLeader) {
        const errorObject = { message: 'El usuario no tiene permisos para editar el proyecto.', status: 403 };
        return { data: null, error: errorObject };
    }

    const currentTimestamp = new Date().toISOString();
    const { data, error } = await supabase
        .from('Proyectos')
        .update({
            nombre: nombre,
            descripcion: descripcion,
            fechaModificacion: currentTimestamp
        })
        .eq('Proyecto_ID', projectId)
        .select()
    return { data, error };
}

async function eliminate(projectId, requestUserId) {

    // Check if the user trying to delete is a leader of the project
    const { data: isLeader, error: leaderError } = await memberService.checkMemberRole(requestUserId, projectId, "Lider");
    if (leaderError) {
        console.error('Error al verificar si el usuario es líder:', leaderError);
        return { data: null, error: leaderError };
    }

    if (!isLeader) {
        const errorObject = { message: 'El usuario no tiene permisos para eliminar el proyecto.', status: 403 };
        return { data: null, error: errorObject };
    }

    const { data, error } = await supabase
        .from('Proyectos')
        .update({
            eliminado: true
        })
        .eq('Proyecto_ID', projectId)
        .select()
    return { data, error };
}

async function getProyectos() {
    const { data, error } = await supabase
        .from('Proyectos')
        .select('*')
    return { data, error };
}

async function getById(id) {
    // Obtener la información básica del proyecto
    const { data: proyectoData, error: proyectoError } = await supabase
        .from('Proyectos')
        .select('*')
        .eq('Proyecto_ID', id)
        .eq('eliminado', false)
        .single();

    if (proyectoError) {
        console.error('Error al obtener proyecto:', proyectoError);
        return { data: null, error: proyectoError };
    }

    // Obtener los miembros del proyecto con sus roles y nombres de roles
    const { data: miembrosProyecto, error: miembrosError } = await supabase
        .from('Miembro_Proyecto')
        .select(`
            Usuario_ID,
            Rol_ID,
            Roles(nombre)  -- Incluye el nombre del rol desde la tabla Roles
        `)
        .eq('Proyecto_ID', id);

    if (miembrosError) {
        console.error('Error al obtener miembros del proyecto:', miembrosError);
        return { data: null, error: miembrosError };
    }

    // Obtener los IDs de los miembros
    const usuarioIds = miembrosProyecto.map(m => m.Usuario_ID);

    // Obtener los detalles de los usuarios (nombre y apellido)
    const { data: usuarios, error: usuariosError } = await supabase
        .from('Usuarios')
        .select('Usuario_ID, nombre, apellido')
        .in('Usuario_ID', usuarioIds);

    if (usuariosError) {
        console.error('Error al obtener detalles de usuarios:', usuariosError);
        return { data: null, error: usuariosError };
    }

    // Combinar los datos de los miembros y los detalles de los usuarios
    const miembros = miembrosProyecto.map(m => {
        const usuario = usuarios.find(u => u.Usuario_ID === m.Usuario_ID);
        return {
            Usuario_ID: m.Usuario_ID,
            nombreCompleto: usuario ? `${usuario.nombre} ${usuario.apellido}` : 'Desconocido',
            Rol_ID: m.Rol_ID,
            nombreRol: m.Roles?.nombre || 'Desconocido',
        };
    });

    // Obtener el total de tareas y las tareas aprobadas del proyecto
    const { data: tareas, error: tareasError } = await supabase
        .from('Tareas')
        .select('Estado_Tarea_ID')
        .eq('Proyecto_ID', id);

    if (tareasError) {
        console.error('Error al obtener tareas:', tareasError);
        return { data: null, error: tareasError };
    }

    // Calcular el total de tareas y las aprobadas
    const totalTareas = tareas.length;
    const tareasAprobadas = tareas.filter(t => t.Estado_Tarea_ID === 4).length;

    // Construir el objeto final del proyecto con todos los detalles adicionales
    const proyecto = {
        ...proyectoData,
        miembros,
        totalTareas,
        tareasAprobadas,
    };

    return { data: proyecto, error: null };
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
        .in('Proyecto_ID', ids)
        .eq('eliminado', false);

    if (errorProyectos) {
        console.error('Error al obtener proyectos:', errorProyectos);
        return { Proyectos: null, error: errorProyectos };
    }

    // Iteramos sobre cada proyecto para agregar los miembros y el creador
    for (let proyecto of Proyectos) {
        // Obtener los miembros del proyecto
        const { data: miembrosProyecto, error: errorMiembros } = await supabase
            .from('Miembro_Proyecto')
            .select('Usuario_ID, gemas')
            .eq('Proyecto_ID', proyecto.Proyecto_ID);

        if (errorMiembros) {
            console.error('Error al obtener miembros del proyecto:', errorMiembros);
            return { Proyectos: null, error: errorMiembros };
        }

        // Obtener los IDs de todos los miembros (incluido el creador si es parte de Miembro_Proyecto)
        let usuarioIds = miembrosProyecto.map(m => m.Usuario_ID);
        const currentUserGems = miembrosProyecto.find(m => m.Usuario_ID === userId)?.gemas;

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
        proyecto.currentUserGems = currentUserGems;
        proyecto.queryingUserId = userId;

        // Eliminar Usuario_ID del objeto proyecto antes de devolverlo
        delete proyecto.Usuario_ID;
    }

    // Devolvemos los proyectos con miembros y creador, pero sin Usuario_ID
    return { Proyectos, error: null };
}



export default {
    create,
    getProyectos,
    getById,
    getByUser,
    update,
    eliminate,
}