import supabaseConfig from "../configs/supabase.js"; 
const { supabase } = supabaseConfig; 

async function create(nombre, precio, accentHex, primaryHex, secondaryHex, backgroundHex, textHex) {
    const { data, error } = await supabase
        .from('Temas')
        .insert([
            {
                nombre: nombre,
                precio: precio,
                accentHex: accentHex,
                primaryHex: primaryHex,
                secondaryHex: secondaryHex,
                backgroundHex: backgroundHex,
                textHex: textHex,
            },
        ])
        .select()
    return { data, error };
}

async function eliminate(id) {
    const { error } = await supabase
        .from('Temas')
        .delete()
        .eq('Tema_ID', id)
    return { error };
}

async function update(nombre, precio, accentHex, primaryHex, secondaryHex, backgroundHex, textHex, id) {
    const { data, error } = await supabase
        .from('Temas')
        .update({ nombre: nombre, precio: precio, accentHex: accentHex, primaryHex: primaryHex, secondaryHex: secondaryHex, backgroundHex: backgroundHex, textHex: textHex })
        .eq('Tema_ID', id)
        .select()
    return { data, error };
}

async function get() {
    const { data, error } = await supabase
        .from('Temas')
        .select('*')
    return { data, error };
}

export default {
    create,
    eliminate,
    update,
    get,
};