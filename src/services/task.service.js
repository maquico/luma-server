import supabaseConfig from "../configs/supabase.js";
import currenciesAndPoints from "../utils/currenciesAndPoints.js";

const { supabase } = supabaseConfig; 

async function create(taskObj) {
    
    const { data, error } = await supabase
        .from('Tareas')
        .insert([
            {
                // requerido
                Proyecto_ID: taskObj.projectId,
                nombre: taskObj.name,
                prioridad: taskObj.priority,
                tiempo: taskObj.time,
                // automatico
                valorGemas: currenciesAndPoints.calculateGemPrice(taskObj.priority, taskObj.time),
                puntosExperiencia: currenciesAndPoints.calculateExperiencePoints(taskObj.priority, taskObj.time),
                // opcional
                fechaInicio: taskObj.startDate,
                fechaFin: taskObj.endDate,
                Usuario_ID: taskObj.userId,
                esCritica: taskObj.isCritical,
                gastos: taskObj.cost,
                presupuesto: taskObj.budget,
                descripcion: taskObj.description,
                etiquetas: taskObj.tags,
            },
        ])
        .select()
    return { data, error };
}

export default {
    create,
};  