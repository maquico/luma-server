import supabase from "../configs/supabase.js";
import generateToken from "../utils/invitation-token.js";
import projectMemberService from "./projectMember.service.js";

const DOMAIN = process.env.DOMAIN || 'http://localhost:5173';

async function create(email, projectId) {
  const token = generateToken();
  const { data, error } = await supabase
    .from('Invitaciones')
    .insert([
    { Proyecto_ID: projectId, correo: email, token: token },
    ])
    .select()

    if (error) {
        console.log(error);
        return { error };
    }
    else {
        const invitationLink = `${DOMAIN}/invite/${token}`;
        return invitationLink;
    }
}

async function getByToken(token) {
  const { data, error } = await supabase
      .from('Invitaciones')
      .select()
      .eq('token', token)
  return { data, error };
}

async function validate(token) {
    // validar existencia de invitacion por token
    let continueValidation = true;
    let errorMessage = null;
    const { data, error } = await getByToken(token);
    
    if (error) {
        console.log(error);
        errorMessage = 'Error finding invitation by token: ' + error.message;
        continueValidation = false;
    }
    // validar si fue usado
    if(data && continueValidation === true){
        const invitation = data[0];
        if(invitation.usado){
            errorMessage = 'Invitation already used';
            continueValidation = false;
        } 
    }
    // validar si expiró
    if(continueValidation === true){
        const invitation = data[0];
        const expirationDate = invitation.fechaExpiracion;
        const currentDate = new Date();
        if( currentDate > expirationDate){
            errorMessage = 'Invitation expired';
            continueValidation = false;
        }
    }
    // validar que el usuario existe
    if(continueValidation === true){
        const invitation = data[0];
        const email = invitation.correo;
        const { dataUsuario, errorUsuario } = await supabase
            .from('Usuarios')
            .select()
            .eq('correo', email)
        if(dataUsuario === null){
            errorMessage = 'User not found';
            continueValidation = false;
        }
    }
    // validar que el usuario no esté ya en el proyecto 
    if (continueValidation === true){
        const invitation = data[0];
        const email = invitation.correo;
        const projectId = invitation.Proyecto_ID;
        const { dataMiembro, errorMiembro } = await projectMemberService.getByEmail(email, projectId);
        if(dataMiembro){
            errorMessage = 'User already in project';
            continueValidation = false;
        }
    }

    return {
      'error': errorMessage,
      'content': continueValidation
    }
}

export default {
    create,
    validate,
};