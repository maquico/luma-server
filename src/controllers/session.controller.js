const session = require('../services/session.service');

// Controller using login service with try catch for error handling
const login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const { data, error } = await session.login(email, password);
        if (error) {
            return res.status(400).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

module.exports = {
    login,
};