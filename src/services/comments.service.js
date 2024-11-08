import supabaseConfig from "../configs/supabase.js";

const { supabase } = supabaseConfig;

async function create (commentObj) {
    const { data, error } = await supabase
        .from('Comentarios_Tarea')
        .insert([
            {
                // required
                Usuario_ID: commentObj.userId,
                Tarea_ID: commentObj.taskId,
                contenido: commentObj.content
            },
        ])
        .select()

    error ? console.log(error) : console.log(`Comment created: ${JSON.stringify(data)}`)

    return { data, error };
}

async function get (columns = '*') {
    const { data, error } = await supabase
        .from('Comentarios_Tarea')
        .select(columns)

    error ? console.log(error) : console.log(`Comments found: ${JSON.stringify(data)}`)

    return { data, error };
}

async function getById (id, columns = '*') {
    const { data, error } = await supabase
        .from('Comentarios_Tarea')
        .select(columns)
        .eq('Comentario_ID', id)

    error ? console.log(error) : console.log(`Comment found: ${JSON.stringify(data)}`)

    return { data, error };
}

async function getByTask (taskId, columns = '*') {
    const { data, error } = await supabase
        .from('Comentarios_Tarea')
        .select(columns)
        .eq('Tarea_ID', taskId)

    error ? console.log(error) : console.log(`Comments found: ${JSON.stringify(data)}`)

    return { data, error };
}

async function getByUser (userId, columns = '*') {
    const { data, error } = await supabase
        .from('Comentarios_Tarea')
        .select(columns)
        .eq('Usuario_ID', userId)

    error ? console.log(error) : console.log(`Comments found: ${JSON.stringify(data)}`)

    return { data, error };
}

async function update (commentId, commentObj) {
    // Add the current timestamp to the commentObj
    const currentTimestamp = new Date().toISOString();
    commentObj.fechaModificacion = currentTimestamp;

    const { data, error } = await supabase
        .from('Comentarios_Tarea')
        .update(commentObj)
        .eq('Comentario_ID', commentId)
        .select();

    if (error) {
        console.log(error);
    } else {
        console.log(`Comment updated: ${JSON.stringify(data)}`);
    }

    return { data, error };
}

async function deleteById (commentId) {
    const { data, error } = await supabase
        .from('Comentarios_Tarea')
        .delete()
        .eq('Comentario_ID', commentId)
        .select()

    error ? console.log(error) : console.log(`Comment deleted: ${JSON.stringify(data)}`)

    return { data, error };
}

export default {
    create,
    get,
    getById,
    getByTask,
    getByUser,
    update,
    deleteById
};