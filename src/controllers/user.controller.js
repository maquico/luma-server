import user from '../services/user.service.js';

// Controller using sign up service with try catch for error handling
const create = async (req, res) => {
  /* #swagger.tags = ['User']
       #swagger.description = 'Endpoint para registrar un usuario.'
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

// Controller for reseting password
const resetPassword = async (req, res) => {
  /* #swagger.tags = ['User']
       #swagger.description = 'Endpoint para resetear la contraseña de un usuario.'
  */
  try {
    const { userId, newPassword } = req.body;
    const { data, error } = await user.resetPassword(userId, newPassword);
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

// Controller for sending otp
const sendOtp = async (req, res) => {
  /* #swagger.tags = ['User']
       #swagger.description = 'Endpoint para enviar un OTP a un usuario.'
  */
  try {
    const { email } = req.body;
    const { data, error } = await user.sendOtp(email);
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

// Controller for verifying otp
const verifyOtp = async (req, res) => {
  /* #swagger.tags = ['User']
       #swagger.description = 'Endpoint para verificar un OTP de un usuario.'
  */
  try {
    const { email, token } = req.body;
    const { data, error } = await user.verifyOtp(email, token);
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
  resetPassword,
  sendOtp,
  verifyOtp,
};