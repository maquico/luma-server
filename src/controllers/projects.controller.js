import project from '../services/projects.service.js';

// Controller using login service with try catch for error handling
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

const getProyectos = async (res) => {
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

export default {
    create,
    getProyectos,
};  