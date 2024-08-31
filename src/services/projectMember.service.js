import supabase from "../configs/supabase.js";

async function create(projectId, userId) {
  const { data, error } = await supabase
    .from('Miembro_Proyecto')
    .insert([
    { Proyecto_ID: projectId, Usuario_ID: userId},
    ])
    .select()
  return { data, error };
}

async function getByEmail(email, projectId) {
  const { data, error } = await supabase
      .from('Miembro_Proyecto')
      .select()
      .eq('correo', email)
      .eq('Proyecto_ID', projectId)
  return { data, error };
}

export default {
    create,
};