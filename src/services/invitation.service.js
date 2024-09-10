import supabase from "../configs/supabase.js";
import generateToken from "../utils/invitation-token.js";
import projectMemberService from "./projectMember.service.js";
import userService from "./user.service.js";
import moment from 'moment-timezone';
import { Resend } from 'resend';

const DOMAIN = process.env.DOMAIN || 'http://localhost:5173';

async function create(email, projectId) {
  const token = generateToken();
  let invitationLink = null;
  const { data, error } = await supabase
    .from('Invitaciones')
    .insert([
    { Proyecto_ID: projectId, correo: email, token: token },
    ])
    .select()

    if (error) {
        console.log(error);
    }
    else {
        //console.log("Invitation created: ", data);
        invitationLink = `${DOMAIN}/invite/${token}`;
    }

    return {
        data: invitationLink,
        error: error
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

async function validate(token, userId) {
    console.log("Validating invitation: ", token);
    let continueValidation = true;
    let errorObject = { message: '', status: 200 };
    let invitation = null;
    let userData = null;
    let content = null;

    // Get the user by id
    const { data: userDataResponse, error: userError } = await userService.getById(userId);
    if (userError) {
        console.log(userError);
        errorObject.message = 'Error finding user by id: ' + userError.message;
        errorObject.status = userError.status;
        continueValidation = false;
    }
    else if (userDataResponse === undefined || userDataResponse === null || userDataResponse.length === 0) {
        errorObject.message = 'User not found';
        errorObject.status = 400;
        continueValidation = false;
    } else {
        userData = userDataResponse;
    }

    // Check if user id corresponds to the user in the token
    if (continueValidation) {
        const { data: invitationData, error: invitationError } = await getByToken(token);
        if (invitationError) {
            console.log(invitationError);
            errorObject.message = 'Error finding invitation by token: ' + invitationError.message;
            errorObject.status = invitationError.status;
            continueValidation = false;
        } else {
            invitation = invitationData[0];

            if (invitation.correo !== userData[0].correo) {
                errorObject.message = 'Current logged in user mail does not match the invitation mail';
                errorObject.status = 400;
                continueValidation = false;
            }
        }
    }

    // Check if user logged in recently
    if (continueValidation && userData) {
        if (userData[0].ultimoInicioSesion === undefined || userData[0].ultimoInicioSesion=== null) {
            errorObject.message = 'User has not logged in yet';
            errorObject.status = 400;
            continueValidation = false;
        }
        else {
            const lastLogin = moment(userData[0].ultimoInicioSesion).utc();
            console.log("Last login: ", lastLogin);
            
            const currentDate = moment().utc();
            const diff = currentDate.diff(lastLogin, 'minutes');
            if (diff > 5) {
                errorObject.message = 'User not logged in recently';
                errorObject.status = 400;
                continueValidation = false;
            }
        }
    }
    
    // Validate if the invitation was used
    if (continueValidation) {
        if (invitation.fueUsado) {
            errorObject.message = 'Invitation already used';
            errorObject.status = 400;
            continueValidation = false;
        }
    }
    // Validate if the invitation expired
    if (continueValidation) {
        const expirationDate = moment(invitation.fechaExpiracion).utc(); 
        const currentDate = moment().utc(); 
        if (currentDate.isAfter(expirationDate)) {
            errorObject.message = 'Invitation expired';
            errorObject.status = 400;
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
            errorObject.message = 'Error finding project member: ' + memberError.message;
            errorObject.status = memberError.status;
            continueValidation = false;
        } else if (memberData.length > 5) {
            errorObject.message = 'User already in project';
            errorObject.status = 400;
            continueValidation = false;
        }   
    }
    // Validate project has not reached the maximum number of members
    if (continueValidation) {
      const { 
        data: projectMembersData,
        error: projectMembersError
      } = await projectMemberService.getByProjectId(invitation.Proyecto_ID);
      
      if(projectMembersError) {
        console.log(projectMembersError);
        errorObject.message = 'Error finding project members: ' + projectMembersError.message;
        errorObject.status = projectMembersError.status;
        continueValidation = false;
      } else if (projectMembersData.length == 6) {
        errorObject.message = 'Project has reached the maximum number of members';
        errorObject.status = 400;
        continueValidation = false;
      }
    }

    if (continueValidation) {
        // Update the invitation to mark it as used and add the user to the project
        const transactionParams = {
            invitation_id: invitation.Invitacion_ID,
            user_id: userData[0].Usuario_ID,
            project_id: invitation.Proyecto_ID
        }
        const { data, error } = await supabase.rpc('handle_invitation_transaction', transactionParams);
        if (error) {
            console.log(error);
            errorObject.message = 'Error handling invitation transaction: ' + error.message;
            errorObject.status = 500;
        } else {
            content = {
                message: 'Invitation validated, user added to project',
                function_data: data
            };
        }
    }
    return {
        error: errorObject,
        data: content,
    };
}

async function sendEmail(email, projectId) {
    console.log("Sending email to: ", email);

    let errorObject = { message: null, status: null };
    let response = null;
    
    const { data: invitationData, error: invitationError } = await create(email, projectId);
    if (invitationError) {
        console.log(invitationError);
        errorObject.message = 'Error creating invitation: ' + invitationError.message;
        errorObject.status = invitationError.status;
    }
    
    try {
      const RESEND_API_KEY = process.env.RESEND_API_KEY;
      const resend = new Resend(RESEND_API_KEY);
      response = await resend.emails.send({
          from: 'Luma - Gamified Project Management <team@luma-gpm.com>',
          to: [email],
          subject: 'Invitation to join project',
          html: '<p>Hello! You have been invited to join a project.</p>' 
              + '<p>Click on the following link to accept the invitation: </p>'
              + `<a href="${invitationData}">${invitationData}</a>`,
        });
        errorObject = null;
    } catch (error) {
        console.error(error);
        errorObject.message = 'Error sending email: ' + error.message;
        errorObject.status = 500;
    }
   
    return {
        data: response,
        error: errorObject,
    };
}

async function getInvitationRoute(token) { 
    console.log("Checking proper invitation route: ", token);
    let continueValidation = true;
    let sign_up_required = false;
    let errorObject = { message: '', status: 200 };
    let invitation = null;
    let userData = null;
    
    // Get the invitation by token
    const { data: invitationData, error: invitationError } = await getByToken(token);

    if (invitationError) {
        console.log(invitationError);
        errorObject.message = 'Error finding invitation by token: ' + invitationError.message;
        errorObject.status = invitationError.status;
        continueValidation = false;
    }

    // Validate if the user exists
    if (continueValidation && invitationData) {
        invitation = invitationData[0];
        const email = invitation.correo;
        const { data: userDataResponse, error: userError } = await userService.getByEmail(email);
        userData = userDataResponse;
        if (userError) {
            console.log(userError);
            errorObject.message = 'Error finding user by email: ' + userError.message;
            errorObject.status = userError.status;
            continueValidation = false;
        } else if (userData === undefined || userData.length === 0) {
            sign_up_required = true;
            errorObject = null;
        }
    }

    return {
        error: errorObject,
        data: sign_up_required,
    };
}
    
export default {
    create,
    validate,
    sendEmail,
    getInvitationRoute,
};