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
    error ? console.log(error) : console.log(`User found: ${JSON.stringify(data)}`)
    return { data, error };
}

async function getById(id, columns = '*') {
    const { data, error } = await supabase
        .from('Usuarios')
        .select(columns)  
        .eq('Usuario_ID', id);

    error ? console.log(error) : console.log(`User found: ${data[0].correo}`)
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

async function updateAuth(userId, updateFields) {
    let returnData = null;

    // Create update object based on provided fields
    const updateObject = {};
    for (const [key, value] of Object.entries(updateFields)) {
        if (value !== null && value !== undefined) {
            updateObject[key] = value;
        }
    }

    // Check if updateObject is empty
    if (Object.keys(updateObject).length === 0) {
        return { data: null, error: "No valid fields to update" };
    }

    const { data: user, error } = await supabaseAdmin.auth.admin.updateUserById(
        userId,
        updateObject
    );

    if (error) {
        console.log(error);
    } else {
        console.log("Updated user: ", user.user.email, ". ", updateObject);
        returnData = {
            email: user.user.email,
        };
    }
    return { data: returnData, error };
}

async function update(userId, updateFields) {
    let returnData = {message: "", data: {}};

    // Create update object based on provided fields
    const updateObject = {};
    for (const [key, value] of Object.entries(updateFields)) {
        if (value !== null && value !== undefined) {
            updateObject[key] = value;
        }
    }

    // Check if updateObject is empty
    if (Object.keys(updateObject).length === 0) {
        return { data: null, error: "No valid fields to update" };
    }

    console.log("Updating user: ", userId, ". ", updateObject);
    // Update user in the Usuarios table
    const { data, error } = await supabase
        .from('Usuarios')
        .update(updateObject)
        .eq('Usuario_ID', userId);
    console.log( data, error);
    if (error) {
        console.log("Error updating on supabase: ", error);
    } else {
        returnData.message = `User with id ${userId} updated`;
        returnData.data.userId = userId;
        returnData.data.updateFields = updateObject;
    }

    return { data: returnData, error };
}


async function get(columns = '*', getDeleted = true) {
    console.log("Getting users from supabase");
    if (getDeleted) {
        const { data, error } = await supabase
            .from('Usuarios')
            .select(columns)
        error ? console.log(error) : console.log('Users found')
        return { data, error };
    } else {
        const { data, error } = await supabase
            .from('Usuarios')
            .select(columns)
            .eq('eliminado', false)
        error ? console.log(error) : console.log('Users found')
        return { data, error };
    }
}

async function deleteById(userId) {
    let returnData = {message: "", data: {}};
    const { data, error } = await supabaseAdmin.auth.admin.deleteUser(
        userId,
        true // enables soft delete 
    );
    
    if (error) {
        console.log("Error deleting user on supabase: ", error);
    } else {
        returnData.message = `User with id ${userId} deleted`;
        returnData.data.userId = userId;
    }

    return { data: returnData, error };
}

async function getByIds(userIds, columns = '*') {
    const { data, error } = await supabase
        .from('Usuarios')
        .select(columns)
        .in('Usuario_ID', userIds);

    error ? console.log(error) : console.log(`Users found: ${JSON.stringify(data)}`)
    return { data, error };
}   

export default {
    create,
    getByEmail,
    getById,
    sendOtp,
    verifyOtp,
    updateAuth,
    update,
    get,
    deleteById,
    getByIds,
};


