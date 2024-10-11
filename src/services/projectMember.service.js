import supabaseConfig from "../configs/supabase.js";
const { supabase } = supabaseConfig;

async function create(projectId, userId, rolId) {
  const { data, error } = await supabase
    .from('Miembro_Proyecto')
    .insert([
      {
        Proyecto_ID: projectId,
        Usuario_ID: userId,
        Rol_ID: rolId
      },
    ])
    .select()
  return { data, error };
}

async function update(projectId, userId, rolId, gemas) {
  const { data, error } = await supabase
    .from('Miembro_Proyecto')
    .update({
      Proyecto_ID: projectId,
      Usuario_ID: userId,
      Rol_ID: rolId,
      gemas: gemas,
    })
    .eq('Proyecto_ID', projectId)
    .eq('Usuario_ID', userId)
    .select();
  return { data, error };
}

async function eliminate(projectId, userId) {
  const { data, error } = await supabase
    .from('Miembro_Proyecto')
    .delete()
    .eq('Proyecto_ID', projectId)
    .eq('Usuario_ID', userId)
  return { data, error };
}

// Función para obtener todos los miembros con el nombre del rol
async function getMiembros() {
  const { data, error } = await supabase
    .from('Miembro_Proyecto')
    .select('*, Roles (nombre)'
    );
  return { data, error };
}

// Función para obtener un miembro por userId y projectId con el nombre del rol
async function getByUserProject(userId, projectId) {
  const { data, error } = await supabase
    .from('Miembro_Proyecto')
    .select('*, Roles (nombre)')
    .eq('Usuario_ID', userId)
    .eq('Proyecto_ID', projectId);

  return { data, error };
}

// Función para obtener miembros por userId con el nombre del rol
async function getByUserId(userId, columns='*,Roles (nombre)') {
  const { data, error } = await supabase
    .from('Miembro_Proyecto')
    .select(columns)
    .eq('Usuario_ID', userId);

  return { data, error };
}

async function getProjectsIdsByUserId(userId) {
  const { data, error } = await getByUserId(userId, 'Proyecto_ID');

  if (error) {
    return { data: null, error };
  }
  // transform data to array of project ids
  const projectsIds = data.map((project) => project.Proyecto_ID);
  return { data: projectsIds, error };

}
// Función para obtener miembros por projectId con el nombre del rol
async function getByProjectId(projectId) {
  const { data, error } = await supabase
    .from('Miembro_Proyecto')
    .select('*, Roles (nombre)')
    .eq('Proyecto_ID', projectId);

  return { data, error };
}

async function checkMemberRole(userId, projectId, roleName) {
  const { data, error } = await getByUserProject(userId, projectId);
  if (error) {
    return { data: null, error };
  }
  // check if the user has the role
  const hasRole = data.some((member) => member.Roles.nombre === roleName);
  
  return { data: hasRole, error: null };
}

export default {
  create,
  update,
  eliminate,
  getMiembros,
  getByUserProject,
  getByUserId,
  getByProjectId,
  getProjectsIdsByUserId,
  checkMemberRole,
};