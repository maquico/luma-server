const supabase = require("../configs/supabase");

async function login(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({
        email: email,
        password: password,
    });
    return { data, error };
}

module.exports = {
    login,
};