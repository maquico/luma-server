import supabaseConfig from "../configs/supabase.js"; 
const { supabase } = supabaseConfig; 

async function create(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({
        email: email,
        password: password,
    });
    return { data, error };
}

export default {
    create,
};