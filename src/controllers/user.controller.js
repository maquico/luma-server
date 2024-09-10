import user from '../services/user.service.js';

// Controller using sign up service with try catch for error handling
const create = async (req, res) => {
  /* #swagger.tags = ['User']
       #swagger.description = 'Endpoint para registrar un usuario.'
       #swagger.parameters['obj'] = {
            in: 'body',
            description: 'Datos del usuario para registro',
            required: true,
            schema: {
                email: 'usuario@correo.com',
                password: 123456,
            }
        }
    */
  try {
    const { email, password, first_name, last_name } = req.body;
    const { data, error } = await user.create(email, password, first_name, last_name);
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
};