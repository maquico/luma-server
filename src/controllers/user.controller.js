import user from '../services/user.service.js';

// Controller using sign up service with try catch for error handling
const create = async (req, res) => {
  /* #swagger.tags = ['User']
       #swagger.description = 'Endpoint para registrar un usuario.'
        #swagger.parameters['obj'] = {
            in: 'body',
            description: 'Datos del usuario',
            required: true,
            schema: {
                email: 'example@gmail.com',
                password: 'password',
                first_name: 'First',
                last_name: 'Last'
            }
        }
  */
  try {
    const { email, password, first_name, last_name } = req.body;
    const { data, error } = await user.create(email, password, first_name, last_name);
    if (error) {
      const statusCode = error.status ? parseInt(error.status) : 500;
      return res.status(statusCode).send(error.message);
    }
    return res.status(200).send(data);
  } catch (error) {
    return res.status(500).send(error.message);
  }
};

// Controller for reseting password
const resetPassword = async (req, res) => {
  /* #swagger.tags = ['User']
       #swagger.description = 'Endpoint para resetear la contraseña de un usuario.'
        #swagger.parameters['obj'] = {
            in: 'body',
            description: 'Datos del usuario',
            required: true,
            schema: {
                userId: 'abc123',
                newPassword: 'password'
            } 
        }
  */
  try {
    const { userId, newPassword } = req.body;
    const fields = { password: newPassword };
    const { data, error } = await user.updateAuth(userId, fields);
    if (error) {
      const statusCode = error.status ? parseInt(error.status) : 500;
      return res.status(statusCode).send(error.message);
    }
    return res.status(200).send(data);
  } catch (error) {
    return res.status(500).send(error.message);
  }
};

// Controller for sending otp
const sendOtp = async (req, res) => {
  /* #swagger.tags = ['User']
       #swagger.description = 'Endpoint para enviar un OTP a un usuario.'
        #swagger.parameters['obj'] = {
            in: 'body',
            description: 'Datos del usuario',
            required: true,
            schema: {
                email: 'example@gmail.com'
            }
        }
  */
  try {
    const { email } = req.body;
    const { data, error } = await user.sendOtp(email);
    if (error) {
                  const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
    }
    return res.status(200).send(data);
  } catch (error) {
    return res.status(500).send(error.message);
  }
};

// Controller for verifying otp
const verifyOtp = async (req, res) => {
  /* #swagger.tags = ['User']
       #swagger.description = 'Endpoint para verificar un OTP de un usuario.'
        #swagger.parameters['obj'] = {
            in: 'body',
            description: 'Datos del usuario',
            required: true,
            schema: {
                email: 'example@gmail.com',
                token: 'abc123'
            }
        }
  */
  try {
    const { email, token } = req.body;
    const { data, error } = await user.verifyOtp(email, token);
    if (error) {
                  const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
    }
    return res.status(200).send(data);
  } catch (error) {
    return res.status(500).send(error.message);
  }
};

const getByIdAdmin = async (req, res) => {
  /* #swagger.tags = ['Admin / User']
     #swagger.description = 'Endpoint para obtener un usuario por su ID (para admins).'
     #swagger.parameters['id'] = { 
         description: 'ID del usuario',
         type: 'string',
         required: true
     }
     #swagger.parameters['columns'] = {
         description: 'Comma-separated list of columns to select (optional)',
         type: 'string',
         required: false
     }
  */
  try {
    const { id } = req.params;
    const { columns } = req.query; // Extract columns from the query parameters

    const { data, error } = await user.getById(id, columns || '*'); // Pass columns if available, otherwise default to '*'
    
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
  /* #swagger.tags = ['User']
     #swagger.description = 'Endpoint para obtener un usuario por su ID (para el cliente).'
     #swagger.parameters['id'] = { 
         description: 'ID del usuario',
         type: 'string',
         required: true
     }
  */
  try {
    const { id } = req.params;
    const columns = "Usuario_ID,nombre,apellido,correo,nivel,monedas,foto,Idioma_ID,ultimoInicioSesion,eliminado"
    const { data, error } = await user.getById(id, columns); 
    
    if (error) {
      const statusCode = error.status ? parseInt(error.status) : 500;
      return res.status(statusCode).send(error.message);
    }

    return res.status(200).send(data);
  } catch (error) {
    return res.status(500).send(error.message);
  }
}

const getAdmin = async (req, res) => {
  /* #swagger.tags = ['Admin / User']
     #swagger.description = 'Endpoint para obtener todos los usuarios.'
  */
  try {
    const { data, error } = await user.get();
    if (error) {
      const statusCode = error.status ? parseInt(error.status) : 500;
      return res.status(statusCode).send(error.message);
    }
    return res.status(200).send(data);
  } catch (error) {
    return res.status(500).send(error.message);
  }
}

const getClient = async (_req, res) => {
  /* #swagger.tags = ['User']
     #swagger.description = 'Endpoint para obtener todos los usuarios (para el cliente).'
  */
  try {
    const columns = "Usuario_ID,nombre,apellido,correo";
    const { data, error } = await user.get(columns, false);
    if (error) {
      const statusCode = error.status ? parseInt(error.status) : 500;
      return res.status(statusCode).send(error.message);
    }
    return res.status(200).send(data);
  } catch (error) {
    return res.status(500).send(error.message);
  }
}

const updateCustomUser = async (req, res) => {
  /* #swagger.tags = ['Admin / User']
     #swagger.description = 'Endpoint para actualizar los datos personalizados del sistema para un usuario.'
     #swagger.parameters['obj'] = {
         in: 'body',
         description: 'Datos para actualizar el usuario',
         required: true,
         schema: {
            nombre: 'Juan',
            apellido: 'Perez',
            experiencia: 100,
            nivel: 2,
            monedas: 100,
            totalGemas: 100,
            tareasAprobadas: 10,
            proyectosCreados: 5,
            esAdmin: false,
            foto: 'ruta foto',
            Idioma_ID: 1,
            eliminado: false
         }
     }
  */
  try {
    const { id } = req.params; // Extract user ID from URL
    let updateFields = { ...req.body }; 

    // Prevent the following fields from being updated
    const restrictedFields = ['correo', 'contraseña'];
    restrictedFields.forEach(field => {
      delete updateFields[field];
    });

    const { data, error } = await user.update(id, updateFields); // Use service function to update user data

    if (error) {
      const statusCode = error.status ? parseInt(error.status) : 500;
      return res.status(statusCode).send(error.message);
    }

    return res.status(200).send(data);
  } catch (error) {
    return res.status(500).send(error.message);
  }
};

const updateAuthUser = async (req, res) => {
  /* #swagger.tags = ['Admin / User']
     #swagger.description = 'Endpoint para actualizar los datos de autenticación de un usuario.'
     #swagger.parameters['obj'] = {
         in: 'body',
         description: 'Datos para actualizar el usuario',
         required: true,
         schema: {
            email: 'example@gmail.com',
            password: 'abc123',
          }
      }
  */
  try {
    const { id } = req.params; // Extract user ID from URL
    const updateFields = req.body; // Extract fields to update from request body

    const { data, error } = await user.updateAuth(id, updateFields); // Use service function to update user data

    if (error) {
      const statusCode = error.status ? parseInt(error.status) : 500;
      return res.status(statusCode).send(error.message);
    }
  
    return res.status(200).send(data);
  } catch (error) {
    return
  }
};
  

const resetEmail = async (req, res) => {
  /* #swagger.tags = ['User']
     #swagger.description = 'Endpoint para actualizar el correo de un usuario.'
     #swagger.parameters['obj'] = {
         in: 'body',
         description: 'Datos para actualizar el correo del usuario',
         required: true,
         schema: {
             userId: 'abc123',
             newEmail: 'nuevoemail@gmail.com'
         }
     }
  */
  try {
    const { userId, newEmail } = req.body;
    const fields = { email: newEmail };

    const { data, error } = await user.updateAuth(userId, fields);

    if (error) {
      const statusCode = error.status ? parseInt(error.status) : 500;
      return res.status(statusCode).send(error.message);
    }

    return res.status(200).send(data);
  } catch (error) {
    return res.status(500).send(error.message);
  }
};

const deleteById = async (req, res) => {
  /* #swagger.tags = ['Admin / User']
     #swagger.description = 'Endpoint para eliminar un usuario.'
     #swagger.parameters['id'] = { 
         description: 'ID del usuario',
         type: 'string',
         required: true
     }
  */
  try {
    const { id } = req.params;
    const { data, error } = await user.deleteById(id);
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
  resetPassword,
  sendOtp,
  verifyOtp,
  getByIdAdmin,
  getById,
  getAdmin,
  getClient,
  updateCustomUser,
  updateAuthUser,
  resetEmail,
  deleteById,
};