import supabaseConfig from "../configs/supabase.js";

const { supabase } = supabaseConfig;

async function create(badgeCategoryObj) {
    const { data, error } = await supabase
        .from('Insignias_Categoria')
        .insert([badgeCategoryObj])
        .select()
    error ? console.log(error) : console.log(`Badge category created: ${data}`)
    return { data, error };
}

async function get(columns = '*') {
    const { data, error } = await supabase
        .from('Insignias_Categoria')
        .select(columns)
    error ? console.log(error) : console.log(`Badge categories found: ${data}`)
    return { data, error };

}

async function getById(id, columns = '*') {
    const { data, error } = await supabase
        .from('Insignias_Categoria')
        .select(columns)
        .eq('Insignia_Cat_ID', id)
    error ? console.log(error) : console.log(`Badge category found: ${data}`)
    return { data, error };
}

async function update(badgeCategoryId, badgeCategoryObj) {
    const { data, error } = await supabase
        .from('Insignias_Categoria')
        .update(badgeCategoryObj)
        .eq('Insignia_Cat_ID', badgeCategoryId)
        .select()
    error ? console.log(error) : console.log(`Badge category updated: ${data}`)
    return { data, error };
}

async function deleteById(badgeCategoryId) {
    const { data, error } = await supabase
        .from('Insignias_Categoria')
        .delete()
        .eq('Insignia_Cat_ID', badgeCategoryId)
        .select()
    error ? console.log(error) : console.log(`Badge category deleted: ${data}`)
    return { data, error };
}

export default {
    create,
    get,
    getById,
    update,
    deleteById
};