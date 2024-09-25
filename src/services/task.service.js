import supabaseConfig from "../configs/supabase.js"; 

const { supabase } = supabaseConfig; 

async function create(taskObj) {
    
    const { data, error } = await supabase
        .from('Tareas')
        .insert([
            {
                // requerido
                Proyecto_ID: taskObj.projectId,
                nombre: taskObj.nombre,
                prioridad: taskObj.prioridad,
                tiempo: taskObj.tiempo,
                // automatico
                fueReclamada: taskObj.fueReclamada,
                valorGemas: taskObj.valorGemas,
                Estado_Tarea_ID: taskObj.estadoTareaId, 
                // opcional
                fechaInicio: taskObj.fechaInicio,
                fechaFin: taskObj.fechaFin,
                Usuario_ID: taskObj.usuarioId,
                esCritica: taskObj.esCritica,
                gasto: taskObj.gasto,
                presupuesto: taskObj.presupuesto,
                descripcion: taskObj.descripcion,
                etiquetas: taskObj.etiquetas,
            },
        ])
        .select()
    return { data, error };
}

export default {
    create,
};  