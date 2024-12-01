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

async function update(projectId, userId, roleId, gemas) {
  const { data, error } = await supabase
    .from('Miembro_Proyecto')
    .update({
      Proyecto_ID: projectId,
      Usuario_ID: userId,
      Rol_ID: roleId,
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
async function getByUserProject(userId, projectId, columns = '*, Roles (nombre)') {
  const { data, error } = await supabase
    .from('Miembro_Proyecto')
    .select(columns)
    .eq('Usuario_ID', userId)
    .eq('Proyecto_ID', projectId);
  return { data, error };
}

// Función para obtener miembros por userId con el nombre del rol
async function getByUserId(userId, columns = '*,Roles (nombre)') {
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
    .select(`
      *,
      Roles (nombre),
      Usuarios (correo, nombre, apellido)
    `)
    .eq('Proyecto_ID', projectId);

  if (error) {
    console.error('Error al obtener miembros del proyecto:', error);
    return { data: null, error };
  }

  // Modificar los datos para incluir nombreCompleto dentro de Usuarios
  const miembros = data.map(miembro => {
    if (miembro.Usuarios) {
      miembro.Usuarios.nombreCompleto = `${miembro.Usuarios.nombre} ${miembro.Usuarios.apellido}`;
    }
    return miembro;
  });

  return { data: miembros, error: null };
}


// async function getByProjectId(projectId) {
//   const { data, error } = await supabase
//     .from('Miembro_Proyecto')
//     .select('*, Roles (nombre)')
//     .eq('Proyecto_ID', projectId);

//   return { data, error };
// }

async function checkMemberRole(userId, projectId, roleName) {
  const { data, error } = await getByUserProject(userId, projectId);
  if (error) {
    return { data: null, error };
  }
  // check if the user has the role
  const hasRole = data.some((member) => member.Roles.nombre === roleName);

  return { data: hasRole, error: null };
}


// Update member role function calling the psql function
async function updateMemberRole(projectId, userId, roleId, requestUserId){
  const functionParams = {
    p_project_id: projectId,
    p_user_id: userId,
    p_role_id: roleId,
    p_request_user_id: requestUserId
  };

  const { data, error } = await supabase.rpc('update_member_role', functionParams);
  if (error) {
    console.log(error);
    return { data: null, error };
  } else {
       // Check the content of the data returned by the function
    if (data.startsWith('Error:')) {
      const errorObject = { message: data, status: 400 };
      return { data: null, error: errorObject };
    } else {
      return {
        data: {
          message: `User ${userId} in project ${projectId} now has role ${roleId}`,
          function_data: data,
        },
        error: null,
      };
    }
  }
}

// Update member role function calling the psql function
async function deleteMemberClient(projectId, userId, requestUserId){
  const functionParams = {
    p_project_id: projectId,
    p_user_id: userId,
    p_request_user_id: requestUserId
  };

  const { data, error } = await supabase.rpc('delete_member_from_project', functionParams);
  if (error) {
    console.log(error);
    return { data: null, error };
  } else {
       // Check the content of the data returned by the function
    if (data.startsWith('Error:')) {
      const errorObject = { message: data, status: 400 };
      return { data: null, error: errorObject };
    } else {
      return {
        data: {
          message: `User ${userId} removed from project ${projectId} `,
          function_data: data,
        },
        error: null,
      };
    }
  }
}

export default {
  create,
  update,
  updateMemberRole,
  eliminate,
  getMiembros,
  getByUserProject,
  getByUserId,
  getByProjectId,
  getProjectsIdsByUserId,
  checkMemberRole,
  deleteMemberClient,
};