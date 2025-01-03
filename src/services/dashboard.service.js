import supabaseConfig from "../configs/supabase.js";

const { supabase } = supabaseConfig;

// Función auxiliar para obtener los nombres de los miembros por sus IDs
async function obtenerNombresMiembros(usuarioIds) {
    const { data: usuarios, error } = await supabase
        .from('Usuarios')
        .select('Usuario_ID, nombre, apellido')
        .in('Usuario_ID', usuarioIds);

    if (error) throw error;
    return usuarios.map(u => ({
        Usuario_ID: u.Usuario_ID,
        nombreCompleto: `${u.nombre} ${u.apellido}`
    }));
}

// 1. Ranking de miembros por total de gemas obtenidas en el proyecto
async function obtenerRankingGemas(projectId) {
    // Obtener gemas disponibles de cada miembro en el proyecto
    const { data: miembros, error: errorMiembros } = await supabase
        .from('Miembro_Proyecto')
        .select('Usuario_ID, gemas')
        .eq('Proyecto_ID', projectId);

    if (errorMiembros) throw errorMiembros;

    // Obtener gemas gastadas por cada miembro en recompensas del proyecto
    const { data: recompensas, error: errorRecompensas } = await supabase
        .from('Historial_Recompensas')
        .select('Usuario_ID, precioCompra, Recompensas(Proyecto_ID)')
        .eq('Recompensas.Proyecto_ID', projectId);

    if (errorRecompensas) throw errorRecompensas;

    // Obtener tareas asignadas por usuario en el proyecto
    const { data: tareas, error: errorTareas } = await supabase
        .from('Tareas')
        .select('Usuario_ID')
        .eq('Proyecto_ID', projectId);

    if (errorTareas) throw errorTareas;

    // Calcular total de gemas obtenidas por usuario
    const gemasGastadasPorUsuario = recompensas.reduce((acc, recompensa) => {
        const usuarioID = recompensa.Usuario_ID;
        if (!acc[usuarioID]) acc[usuarioID] = 0;
        acc[usuarioID] += recompensa.precioCompra;
        return acc;
    }, {});

    // Calcular total de tareas asignadas por usuario
    const tareasPorUsuario = tareas.reduce((acc, tarea) => {
        const usuarioID = tarea.Usuario_ID;
        if (!acc[usuarioID]) acc[usuarioID] = 0;
        acc[usuarioID]++;
        return acc;
    }, {});

    // Construir el ranking
    const ranking = miembros.map(miembro => {
        const gemasDisponibles = miembro.gemas || 0;
        const gemasGastadas = gemasGastadasPorUsuario[miembro.Usuario_ID] || 0;
        const gemasTotales = gemasDisponibles + gemasGastadas;
        const totalTareas = tareasPorUsuario[miembro.Usuario_ID] || 0;

        return {
            Usuario_ID: miembro.Usuario_ID,
            gemasTotales,
            totalTareas
        };
    });

    // Obtener nombres de los miembros y asignarlos al ranking
    const usuarioIds = ranking.map(r => r.Usuario_ID);
    const nombresMiembros = await obtenerNombresMiembros(usuarioIds);

    return ranking.map(r => ({
        nombre: nombresMiembros.find(n => n.Usuario_ID === r.Usuario_ID).nombreCompleto,
        gemasTotales: r.gemasTotales,
        totalTareas: r.totalTareas
    })).sort((a, b) => b.gemasTotales - a.gemasTotales);
}


// 2. Conteo de tareas por estado
async function obtenerConteoTareas(projectId) {
    const { data, error } = await supabase
        .from('Tareas')
        .select('Estado_Tarea_ID', { count: 'exact' })
        .eq('Proyecto_ID', projectId);

    if (error) throw error;

    return {
        total: data.length,
        pendientes: data.filter(t => [1, 2].includes(t.Estado_Tarea_ID)).length, // Estados pendiente (1 y 2)
        completadas: data.filter(t => t.Estado_Tarea_ID === 3).length,          // Estado completada (3)
        aprobadas: data.filter(t => t.Estado_Tarea_ID === 4).length             // Estado aprobada (4)
    };
}

// 3. Tareas pendientes del usuario en el proyecto
async function obtenerTareasPendientesUsuario(projectId, userId) {
    const { data, error } = await supabase
        .from('Tareas')
        .select('Tarea_ID, nombre, descripcion, Estado_Tarea_ID')
        .eq('Proyecto_ID', projectId)
        .eq('Usuario_ID', userId)
        .in('Estado_Tarea_ID', [1, 2]); // Estados pendientes (1: nuevo, 2: en progreso)

    if (error) throw error;
    return data;
}

// 4. Tareas aprobadas en el proyecto por usuario
async function obtenerTareasAprobadasPorUsuario(projectId) {
    const { data, error } = await supabase
        .from('Tareas')
        .select('Usuario_ID')
        .eq('Proyecto_ID', projectId)
        .eq('Estado_Tarea_ID', 4); // Estado aprobado

    if (error) throw error;

    const tareasPorUsuario = data.reduce((acc, tarea) => {
        const usuarioID = tarea.Usuario_ID;
        if (!acc[usuarioID]) acc[usuarioID] = 0;
        acc[usuarioID]++;
        return acc;
    }, {});

    // Obtener nombres de los usuarios y asignarlos al resultado
    const usuarioIds = Object.keys(tareasPorUsuario);
    const nombresUsuarios = await obtenerNombresMiembros(usuarioIds);

    return Object.entries(tareasPorUsuario).map(([usuarioID, tareasAprobadas]) => ({
        nombre: nombresUsuarios.find(n => n.Usuario_ID === usuarioID).nombreCompleto,
        tareasAprobadas
    }));
}

export default {
    obtenerRankingGemas,
    obtenerConteoTareas,
    obtenerTareasPendientesUsuario,
    obtenerTareasAprobadasPorUsuario,
};