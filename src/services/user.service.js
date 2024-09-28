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
  error ? console.log(error) : console.log(`User created: ${data.user.email}`)
  return { data, error };
}

async function getByEmail(email) {
    const { data, error } = await supabase
        .from('Usuarios')
        .select()
        .eq('correo', email)
    error ? console.log(error) : console.log(`User found: ${data[0].correo}`)
    return { data, error };
}

async function getById(id, columns = '*') {
    const { data, error } = await supabase
        .from('Usuarios')
        .select(columns)  
        .eq('Usuario_ID', id);

    error ? console.log(error) : console.log('User found: ${data[0].correo}')
    return { data, error };
}


async function sendOtp(email){
    const { data, error } = await supabase.auth.signInWithOtp({
        email: email,
        options: {
          shouldCreateUser: false,
        },
    })
    error ? console.log(error) : console.log(`OTP sent to user: ${email}`)
    return { data, error };
}

async function verifyOtp(email, token){
    const { data, error } = await supabase.auth.verifyOtp({
        email, 
        token, 
        type: 'email'
    })
    error ? console.log(error) : console.log(`OTP verified for user: ${email}`)

    return { data, error };
}

async function resetPassword(userId, newPassword) {
    let returnData = null;
    const { data: user, error } = await supabaseAdmin.auth.admin.updateUserById(
        userId,
        { password: newPassword }
    )
    if (error) {
        console.log(error)
    }
    else {
        console.log("Password reset for user: ", user.user.email)
        returnData = {
            email: user.user.email,
            aud: user.user.aud,
        }  
    }
    return { data: returnData, error };
}

export default {
    create,
    getByEmail,
    getById,
    sendOtp,
    verifyOtp,
    resetPassword,
};


