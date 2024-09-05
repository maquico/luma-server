import invitation from '../services/invitation.service.js';

// Controller using create service with try catch for error handling
const create = async (req, res) => {
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

// Controller using validate service with try catch for error handling
const validate = async (req, res) => {
    try {
        const { token } = req.params;
        const result = await invitation.validate(token);
        if (result.error !== null) {
            return res.status(400).send(result);
        }
        return res.status(200).send(result);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using sendEmail service with try catch for error handling
const sendEmail = async (req, res) => {
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

export default {
    create,
    validate,
    sendEmail,
};