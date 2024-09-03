import user from '../services/user.service.js';

// Controller using sign up service with try catch for error handling
const create = async (req, res) => {
  try {
    const { email, password, first_name, last_name } = req.body;
    console.log(req.body);
    const { data, error } = await user.create(email, password, first_name, last_name);
    if (error) {
      return res.status(400).send(error.message);
    }
    return res.status(200).send(data);
  } catch (error) {
    return res.status(500).send(error.message);
  }
};

export default {
  create,
};