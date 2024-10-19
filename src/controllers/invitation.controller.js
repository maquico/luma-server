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
        console.log(data);
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
    /* #swagger.tags = ['Admin / Invitation']
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

const update = async (req, res) => {
    /* #swagger.tags = ['Admin / Invitation']
        #swagger.description = 'Endpoint para actualizar una invitación.'
        #swagger.parameters['id'] = { description: 'ID de la invitación', required: true }
        #swagger.parameters['updateObject'] = {
            in: 'body',
            description: 'Datos de la invitación',
            required: true,
            schema: {
                Proyecto_ID: 123456,
                correo: 'example@gmail.com',
                token: 'abc123',
                fechaExpiracion: '2021-12-31T23:59:59.999Z',
                fueUsado: false
            }
        }
    */
    try {
        const invitationId = req.params.id;
        const updateObject  = req.body;
        const { data, error } = await invitation.update(invitationId, updateObject);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

const get = async (req, res) => {
    /* #swagger.tags = ['Admin / Invitation']
        #swagger.description = 'Endpoint para obtener todas las invitaciones.'
    */
    try {
        const { data, error } = await invitation.get();
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

const getById = async (req, res) => {
    /* #swagger.tags = ['Admin / Invitation']
        #swagger.description = 'Endpoint para obtener una invitación por ID.'
        #swagger.parameters['id'] = { description: 'ID de la invitación', required: true }
    */
    try {
        const invitationId = req.params.id;
        const { data, error } = await invitation.getById(invitationId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

const getByToken = async (req, res) => {
    /* #swagger.tags = ['Admin / Invitation']
        #swagger.description = 'Endpoint para obtener una invitación por token.'
        #swagger.parameters['token'] = { description: 'Token de la invitación', required: true }
    */
    try {
        const token = req.params.token;
        const { data, error } = await invitation.getByToken(token);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

const deleteById = async (req, res) => {
    /* #swagger.tags = ['Admin / Invitation']
        #swagger.description = 'Endpoint para eliminar una invitación por ID.'
        #swagger.parameters['id'] = { description: 'ID de la invitación', required: true }
    */
    try {
        const invitationId = req.params.id;
        const { data, error } = await invitation.deleteById(invitationId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

export default {
    create,
    update,
    get,
    getById,
    getByToken,
    deleteById,
    validate,
    sendEmail,
    getInvitationRoute,
};