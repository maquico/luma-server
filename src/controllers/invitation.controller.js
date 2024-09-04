import invitation from '../services/invitation.service.js';

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    try {
        const { email, projectId } = req.body;
        const { data, error } = await invitation.create(email, projectId);
        if (error) {
            const errorCode = parseInt(error.code, 10)
            return res.status(errorCode).send(error.message);
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
            return res.status(400).send(result.error);
        }
        return res.status(200).send(result);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

export default {
    create,
    validate,
};