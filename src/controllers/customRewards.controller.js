import rewards from '../services/customRewards.service.js'

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    try {
        const { projectId, iconoId, nombre, descripcion, precio, cantidad, limite } = req.body;
        const { data, error } = await rewards.create(projectId, iconoId, nombre, descripcion, precio, cantidad, limite);
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
        const { error } = await rewards.eliminate(id);
        if (error) {
            const errorStatusCode = parseInt(error.status, 10)
            console.log(errorStatusCode);
            return res.status(errorStatusCode).send(error.message);
        }
        return res.status(200).send('Recompensa eliminada');
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using update service with try catch for error handling
const update = async (req, res) => {
    try {
        const { iconoId, nombre, descripcion, precio, cantidad, limite, id } = req.body;
        const { data, error } = await rewards.update(iconoId, nombre, descripcion, precio, cantidad, limite, id);
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

// Controller using getRecompensas service with try catch for error handling
const getRecompensas = async (req, res) => {
    try {
        const { data, error } = await rewards.getRecompensas();
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
    getRecompensas,
};