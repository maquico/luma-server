import supabaseConfig from "../configs/supabase.js"; 
const { supabase } = supabaseConfig; 

async function create(projectId, userId) {
  const { data, error } = await supabase
    .from('Miembro_Proyecto')
    .insert([
      { Proyecto_ID: projectId, Usuario_ID: userId },
    ])
    .select()
  return { data, error };
}

async function getByUserId(userId) {
  const { data, error } = await supabase
    .from('Miembro_Proyecto')
    .select()
    .eq('Usuario_ID', userId)
  return { data, error };
}

async function getByProjectId(projectId) {
  const { data, error } = await supabase
      .from('Miembro_Proyecto')
      .select()
      .eq('Proyecto_ID', projectId)
  return { data, error };
}

export default {
    create,
    getByUserId,
    getByProjectId,
};