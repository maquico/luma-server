import supabaseConfig from "../configs/supabase.js";
import currenciesAndPoints from "../utils/currenciesAndPoints.js";
import tagsUtils from "../utils/tagsUtils.js";

const { supabase } = supabaseConfig;

async function create(taskObj) {

    if (taskObj.tags) {
        // Validate tags
        const { valid, message } = tagsUtils.validateTags(taskObj.tags);
        if (!valid) {
            console.log(`Error validating tags when creating task: ${message}`);
            return { data: null, error: {message: message} };
        }
        const processedTags = tagsUtils.processTags(taskObj.tags);
        taskObj.tags = processedTags;
    }

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

async function update(taskId, taskObj) {

    if (taskObj.etiquetas) {
        // Validate tags
        const { valid, message } = tagsUtils.validateTags(taskObj.etiquetas);
        if (!valid) {
            console.log(`Error validating tags when updating task with ID ${taskId}: ${message}`);
            return { data: null, error: {message: message} };
        }
        const processedTags = tagsUtils.processTags(taskObj.etiquetas);
        taskObj.etiquetas = processedTags;
    }
    
    let returnData = {message: "", data: {}};
    const { data, error } = await supabase
        .from('Tareas')
        .update(taskObj)
        .eq('Tarea_ID', taskId);
        if (error) {
            console.log("Error updating task on supabase: ", error);
        } else {
            returnData.message = `Task with id ${taskId} updated with: ${JSON.stringify(taskObj, null, 2)}`;
            returnData.data.taskId = taskId;
        }
    return { data: returnData, error };
}

async function getById(taskId, columns = '*') {
    const { data, error } = await supabase
        .from('Tareas')
        .select(columns)
        .eq('Tarea_ID', taskId);
    
    error ? console.log(error) : console.log(`Task with ID ${taskId} found: ${JSON.stringify(data, null, 2)}`);
    return { data, error };
}

async function getByProjectId(projectId, columns = '*') {
    const { data, error } = await supabase
        .from('Tareas')
        .select(columns)
        .eq('Proyecto_ID', projectId);
    
    error ? console.log(error) : console.log(`Tasks found for project with ID ${projectId}: ${JSON.stringify(data, null, 2)}`);
    return { data, error };
}

async function getTagsByProjectId(projectId) {
    const { data, error } = await getByProjectId(projectId, 'etiquetas');
    
    if (error) {
        console.log(error);
        return { data: null, error };
    } else {
        // Extract and process tags
        const tags = data
            .map(item => item.etiquetas.split(',')) // Split tags by comma
            .flat() // Flatten the array
            .map(tag => tag.trim()) // Trim whitespace
            .filter((tag, index, self) => tag && self.indexOf(tag) === index); // Remove duplicates and empty strings

        console.log(`Tags found for project with ID ${projectId}: ${JSON.stringify(tags, null, 2)}`);
        return { data: tags, error: null };
    }
}

async function get(){
    const { data, error } = await supabase
        .from('Tareas')
        .select()
    error ? console.log(error) : console.log(`All tasks found: ${JSON.stringify(data, null, 2)}`);
    return { data, error };
}

async function deleteById(taskId) {
    let returnData = {message: "", data: {}};
    const { data, error } = await supabase
        .from('Tareas')
        .delete()
        .eq('Tarea_ID', taskId);

        if (error) {
            console.log("Error deleting task on supabase: ", error);
        } else {
            returnData.message = `Task with id ${taskId} deleted`;
            returnData.data.taskId = taskId;
        }
    return { data: returnData, error };
}

export default {
    create,
    get,
    getById,
    getByProjectId,
    getTagsByProjectId,
    update,
    deleteById,
};