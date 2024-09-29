import invitation from '../services/invitation.service.js';

// Controller using sendEmail service with try catch for error handling
const sendEmail = async (req, res) => {
    /* #swagger.tags = ['Invitation']
       #swagger.description = 'Endpoint para enviar una invitación a un proyecto por correo.'
       #swagger.parameters['obj'] = {
              in: 'body',
              description: 'Datos de la invitación',
              required: true,
              schema: {
                email: 'example@gmail.com',
                projectId: 123456
                }
        }  

    */
    try {
        const { email, projectId } = req.body;
        const { data, error } = await invitation.sendEmail(email, projectId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

const getInvitationRoute = async (req, res) => {
    /* #swagger.tags = ['Invitation']
       #swagger.description = 'Endpoint para obtener validar si redirigir al signup o al login.'
         #swagger.parameters['token'] = {
                in: 'path',
                description: 'Token de la invitación',
                required: true,
                type: 'string'
        }
    */
    try {
        const { token } = req.params;
        const { data, error } = await invitation.getInvitationRoute(token);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
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
        #swagger.parameters['obj'] = {
                in: 'body',
                description: 'Datos de la invitación',
                required: true,
                schema: {
                token: 'eak182mane1',
                userId: 'abc123'
                }
        }
    */
    try {
        const { token, userId } = req.body;
        const { data, error} = await invitation.validate(token, userId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
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
        #swagger.parameters['obj'] = {
                in: 'body',
                description: 'Datos de la invitación',
                required: true,
                schema: {
                email: 'example@gmail.com',
                projectId: 123456
                }
        }
    */
    try {
        const { email, projectId } = req.body;
        const { data, error } = await invitation.create(email, projectId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
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