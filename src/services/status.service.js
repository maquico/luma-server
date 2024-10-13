import supabaseConfig from "../configs/supabase.js"; 
const { supabase } = supabaseConfig; 

async function get() {
    const { data, error } = await supabase
        .from('Estados')
        .select()
    error ? console.log(error) : console.log(`Status found: ${data}`)
    return { data, error };
}

export default {
    get
};