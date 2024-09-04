import supabase from "../configs/supabase.js";
import generateToken from "../utils/invitation-token.js";
import projectMemberService from "./projectMember.service.js";
import userService from "./user.service.js";
import moment from 'moment-timezone';

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
        console.log("Invitation created: ", data);
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

async function update(invitationId) {
    const { data, error } = await supabase
        .from('Invitaciones')
        .update({ fueUsado: true })
        .eq('Invitacion_ID', invitationId)
    return { data, error };
}

async function validate(token) {
    let continueValidation = true;
    let sign_up_required = false;
    let errorMessage = null;
    let invitation = null;
    let userData = null;
    let content = null;

    // Get the invitation by token
    const { data: invitationData, error: invitationError } = await getByToken(token);

    if (invitationError) {
        console.log(invitationError);
        errorMessage = 'Error finding invitation by token: ' + invitationError.message;
        continueValidation = false;
    }
    
    // Validate if the invitation was used
    if (invitationData && continueValidation) {
        invitation = invitationData[0];
        if (invitation.fueUsado) {
            errorMessage = 'Invitation already used';
            continueValidation = false;
        }
    }
    // Validate if the invitation expired
    if (continueValidation) {
        const expirationDate = moment(invitation.fechaExpiracion).utc(); 
        const currentDate = moment().utc(); 
        if (currentDate.isAfter(expirationDate)) {
            errorMessage = 'Invitation expired';
            continueValidation = false;
        }
    }
    
    // Validate if the user exists
    if (continueValidation) {
        const email = invitation.correo;
        const { data: userDataResponse, error: userError } = await userService.getByEmail(email);
        userData = userDataResponse;
        if (userError) {
            console.log(userError);
            errorMessage = 'Error finding user by email: ' + userError.message;
            continueValidation = false;
        } else if (userData === undefined || userData.length === 0) {
            errorMessage = 'User not found';
            sign_up_required = true;
            continueValidation = false;
        }
    }
    // Validate that the user is not already in the project 
    if (continueValidation) {
        const { data: memberData,
                error: memberError
              } = await projectMemberService.getByUserId(userData[0].Usuario_ID);
        if (memberError) {
            console.log(memberError);
            errorMessage = 'Error finding project member: ' + memberError.message;
            continueValidation = false;
        } else if (memberData.length > 0) {
            errorMessage = 'User already in project';
            continueValidation = false;
        }
    }

    if (continueValidation) {
        // Update the invitation to mark it as used
        const { data: updateData, error: updateError } = await update(invitation.Invitacion_ID);
        if (updateError) {
            console.log(updateError);
            errorMessage = 'Error updating invitation: ' + updateError.message;
        } else {
            // Add user to project members
            console.log("update data: ", updateData);
            const userId = userData[0].Usuario_ID;
            const projectId = invitation.Proyecto_ID;
            const { data: memberData, error: memberError } = await projectMemberService.create(projectId, userId);
            if (memberError) {
                console.log(memberError);
                errorMessage = 'Error adding user to project members: ' + memberError.message;
            } else {
                content = memberData;
            }
        }
    }
    return {
        error: errorMessage,
        content: content,
        sign_up: sign_up_required,
    };
}

export default {
    create,
    validate,
};