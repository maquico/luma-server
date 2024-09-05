import supabase from "../configs/supabase.js";

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

export default {
    create,
    getByEmail,
};
