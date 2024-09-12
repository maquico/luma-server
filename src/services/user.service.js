import supabaseConfig from "../configs/supabase.js"; 
const { supabase, supabaseAdmin } = supabaseConfig; 

async function create(email, password, first_name, last_name) {
    const { data, error } = await supabase.auth.signUp({
        email: email,
        password: password,
        options: {
          data: {
            first_name: first_name,
            last_name: last_name,
          },
        },
      })
  return { data, error };
}

async function getByEmail(email) {
    const { data, error } = await supabase
        .from('Usuarios')
        .select()
        .eq('correo', email)
    return { data, error };
}

async function getById(id) {
    const { data, error } = await supabase
        .from('Usuarios')
        .select()
        .eq('Usuario_ID', id)
    return { data, error };
}

async function sendOtp(email){
    const { data, error } = await supabase.auth.signInWithOtp({
        email: email,
        options: {
          shouldCreateUser: false,
        },
    })
    return { data, error };
}

async function verifyOtp(email, token){
    const { data, error } = await supabase
    .auth.verifyOtp({email, token, type: 'email'})

    return { data, error };
}

async function resetPassword(userId, newPassword) {
    const { data: user, error } = await supabaseAdmin.auth.admin.updateUserById(
        userId,
        { password: newPassword }
    )
    if (error) {
        console.log(error)
    }
    else {
        console.log("Password reset for user: ", user.mail)
    }

    return { data: user, error };
}

export default {
    create,
    getByEmail,
    getById,
    sendOtp,
    verifyOtp,
    resetPassword,
};


