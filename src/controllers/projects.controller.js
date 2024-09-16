import project from '../services/projects.service.js';

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    /* #swagger.tags = ['Projects']
         #swagger.description = 'Endpoint para crear un proyecto.'
    */
    try {
        const { nombre, descripcion, userId } = req.body;
        const { data, error } = await project.create(nombre, descripcion, userId);
        if (error) {
            const errorStatusCode = parseInt(error.status, 10)
            console.log(errorStatusCode);
            return res.status(errorStatusCode).send(error.message);
        }
        return res.status(201).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using getProyectos service with try catch for error handling
const getProyectos = async (req, res) => {
    /* #swagger.tags = ['Projects']
         #swagger.description = 'Endpoint para obtener todos los proyectos.'
    */
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

// Controller using getById service with try catch for error handling
const getById = async (req, res) => {
    /* #swagger.tags = ['Projects']
         #swagger.description = 'Endpoint para obtener un proyecto por id.'
    */
    try {
        const { id } = req.body;
        const { data, error } = await project.getById(id);
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
    /* #swagger.tags = ['Projects']
         #swagger.description = 'Endpoint para obtener un proyecto por id de usuario.'
    */
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
    getById,
    getByUser,
};  