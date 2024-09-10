import invitation from '../services/invitation.service.js';

// Controller using sendEmail service with try catch for error handling
const sendEmail = async (req, res) => {
    /* #swagger.tags = ['Invitation']
        #swagger.description = 'Endpoint para enviar una invitación a un proyecto por correo.'
    */
    try {
        const { email, projectId } = req.body;
        const { data, error } = await invitation.sendEmail(email, projectId);
        if (error) {
          const errorStatusCode = parseInt(error.status, 10)
          console.log(errorStatusCode);
          return res.status(errorStatusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

const getInvitationRoute = async (req, res) => {
    /* #swagger.tags = ['Invitation']
        #swagger.description = 'Endpoint para obtener validar si redirigir al signup o al login.'
    */
    try {
        const { token } = req.params;
        const { data, error } = await invitation.getInvitationRoute(token);
        if (error) {
          const errorStatusCode = parseInt(error.status, 10)
          console.log("Error code: ", errorStatusCode);
          console.log("Error message: ", error.message);
          return res.status(errorStatusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using validate service with try catch for error handling
const validate = async (req, res) => {
    /* #swagger.tags = ['Invitation']
        #swagger.description = 'Endpoint para validar una invitación.'
    */
    try {
        const { token, userId } = req.body;
        const { data, error} = await invitation.validate(token, userId);
        if (error) {
          const errorStatusCode = parseInt(error.status, 10)
          console.log(errorStatusCode);
          return res.status(errorStatusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    /* #swagger.tags = ['Invitation']
        #swagger.description = 'Endpoint para crear una invitación.'
    */
    try {
        const { email, projectId } = req.body;
        const { data, error } = await invitation.create(email, projectId);
        if (error) {
          const errorStatusCode = parseInt(error.status, 10)
          console.log(errorStatusCode);
          return res.status(errorStatusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

export default {
    create,
    validate,
    sendEmail,
    getInvitationRoute,
};