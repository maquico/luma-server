import supabase from "../configs/supabase.js";

async function login(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({
        email: email,
        password: password,
    });
    return { data, error };
}

export default {
    login,
};