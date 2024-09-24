import supabaseConfig from "../configs/supabase.js"; 

const { supabase } = supabaseConfig; 

async function create(projectId, iconoId, nombre, descripcion, precio, cantidad, limite) {
    const { data, error } = await supabase
        .from('Tareas')
        .insert([
            {
                Proyecto_ID: projectId,
                Estado_tarea_ID: estadoTareaId,
                etiquetas: etiquetas,
                nombre: nombre,
                descripcion: descripcion,
                prioridad: prioridad,
                valorGemas: valorGemas,
                fechaInicio: fechaInicio,
                fechaFinal: fechaFinal,
                fueReclamada: fueReclamada,
                Usuario_ID: usuarioId,
                //esCritica: esCritica,
                gasto: gasto,
                presupuesto: presupuesto,
                tiempo: tiempo
            },
        ])
        .select()
    return { data, error };
}

export default {
    create,
};  