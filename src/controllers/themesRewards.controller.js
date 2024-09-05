import themes from '../services/themesRewards.service.js'

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    try {
        const { nombre, precio, accentHex, primaryHex, secondaryHex, backgroundHex, textHex } = req.body;
        const { data, error } = await themes.create(nombre, precio, accentHex, primaryHex, secondaryHex, backgroundHex, textHex);
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

// Controller using eliminate service with try catch for error handling
const eliminate = async (req, res) => {
    try {
        const { id } = req.body;
        const { error } = await themes.eliminate(id);
        if (error) {
            const errorStatusCode = parseInt(error.status, 10)
            console.log(errorStatusCode);
            return res.status(errorStatusCode).send(error.message);
        }
        return res.status(200).send('Tema eliminado');
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using update service with try catch for error handling
const update = async (req, res) => {
    try {
        const { nombre, precio, accentHex, primaryHex, secondaryHex, backgroundHex, textHex, id } = req.body;
        const { data, error } = await themes.update(nombre, precio, accentHex, primaryHex, secondaryHex, backgroundHex, textHex, id);
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

// Controller using getTemas service with try catch for error handling
const getTemas = async (req, res) => {
    try {
        const { data, error } = await themes.getTemas();
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
    eliminate,
    update,
    getTemas,
};