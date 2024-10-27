import supabaseConfig from "../configs/supabase.js";

const { supabase } = supabaseConfig;

async function create(badgeCategoryObj) {
    console.log(badgeCategoryObj);
    const { data, error } = await supabase
        .from('Insignia_Categoria')
        .insert([
            {
                // required
                nombre: badgeCategoryObj.name,
                campoComparativo: badgeCategoryObj.comparativeField
            },
        ])
        .select()
    console.log(data, error);
    error ? console.log(error) : console.log(`Badge category created: ${JSON.stringify(data)}`)
    return { data, error };
}

async function get(columns = '*') {
    const { data, error } = await supabase
        .from('Insignia_Categoria')
        .select(columns)
    error ? console.log(error) : console.log(`Badge categories found: ${JSON.stringify(data)}`)
    return { data, error };

}

async function getById(id, columns = '*') {
    const { data, error } = await supabase
        .from('Insignia_Categoria')
        .select(columns)
        .eq('Insignia_Cat_ID', id)
    error ? console.log(error) : console.log(`Badge category found: ${JSON.stringify(data)}`)
    return { data, error };
}

async function update(badgeCategoryId, badgeCategoryObj) {
    // Add the current timestamp to the badgeCategoryObj
    const currentTimestamp = new Date().toISOString();
    badgeCategoryObj.fechaModificacion = currentTimestamp;

    const { data, error } = await supabase
        .from('Insignia_Categoria')
        .update(badgeCategoryObj)
        .eq('Insignia_Cat_ID', badgeCategoryId)
        .select();

    if (error) {
        console.log(error);
    } else {
        console.log(`Badge category updated: ${JSON.stringify(data)}`);
    }

    return { data, error };
}

async function deleteById(badgeCategoryId) {
    const { data, error } = await supabase
        .from('Insignia_Categoria')
        .delete()
        .eq('Insignia_Cat_ID', badgeCategoryId)
        .select()
    error ? console.log(error) : console.log(`Badge category deleted: ${JSON.stringify(data)}`)
    return { data, error };
}

export default {
    create,
    get,
    getById,
    update,
    deleteById
};