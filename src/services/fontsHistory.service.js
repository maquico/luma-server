import supabaseConfig from "../configs/supabase.js"; 

const { supabase } = supabaseConfig; 

async function getByUserId(userId) {
    const { data, error } = await supabase
        .from('Historial_Fuentes')
        .select()
        .eq('Usuario_ID', userId)
    
    error ? console.log(error) : console.log(`Bought fonts found: ${data.length}`);
    return { data, error };
}

export default {
    getByUserId,
};