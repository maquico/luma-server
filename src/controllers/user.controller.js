const user = require('../services/user.service');

// Controller using sign up service with try catch for error handling
const signUp = async (req, res) => {
  try {
    const { email, password, first_name, last_name } = req.body;
    const { data, error } = await user.signUp(email, password, first_name, last_name);
    if (error) {
      return res.status(400).send(error.message);
    }
    return res.status(200).send(data);
  } catch (error) {
    return res.status(500).send(error.message);
  }
};

module.exports = {
  signUp,
};