import supabase from "../configs/supabase.js";
import generateToken from "../utils/invitation-token.js";

async function create(projectId, email) {
  const token = generateToken();
  const { data, error } = await supabase
    .from('Invitaciones')
    .insert([
    { Proyecto_ID: projectId, correo: email, token: token },
    ])
    .select()
  return { data, error };
}

export default {
    create,
};