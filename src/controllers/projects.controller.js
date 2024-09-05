import project from '../services/projects.service.js';

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    try {
        const { nombre, descripcion } = req.body;
        const { data, error } = await project.create(nombre, descripcion);
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

// Controller using getProyectos service with try catch for error handling
const getProyectos = async (req, res) => {
    try {
        const { data, error } = await project.getProyectos();
        if (error) {
            const errorStatusCode = parseInt(error.status, 10)
            console.log(errorStatusCode);
            return res.status(errorStatusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

// Controller using getByUser service with try catch for error handling
const getByUser = async (req, res) => {
    try {
        const { userId } = req.body;
        const { Proyectos, error } = await project.getByUser(userId);
        if (error) {
            const errorStatusCode = parseInt(error.status, 10)
            console.log(errorStatusCode);
            return res.status(errorStatusCode).send(error.message);
        }
        return res.status(200).send(Proyectos);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}



export default {
    create,
    getProyectos,
    getByUser,
};  