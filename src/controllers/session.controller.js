import session from '../services/session.service.js';

// Controller using login service with try catch for error handling
const create = async (req, res) => {
    /* #swagger.tags = ['Session']
         #swagger.description = 'Endpoint para iniciar sesión.'
         #swagger.parameters['obj'] = {
              in: 'body',
              description: 'Datos del usuario para iniciar sesión',
              required: true,
              schema: {
                email: 'usuario@correo.com',
                password: 'password',
            }
        }
    */
    try {
        const { email, password } = req.body;
        const { data, error } = await session.create(email, password);
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
};