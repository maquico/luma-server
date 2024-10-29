import roles from '../services/roles.service.js';

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    /* #swagger.tags = ['Roles']
       #swagger.description = 'Endpoint para registrar un rol.'
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos del rol',
           required: true,
           schema: {
               nombre: 'Rol',
               descripcion: 'Descripción del rol'
           }
       }
    */
    try {
        const { nombre, descripcion } = req.body;
        const { data, error } = await roles.create(nombre, descripcion);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using update service with try catch for error handling
const update = async (req, res) => {
    /* #swagger.tags = ['Roles']
       #swagger.description = 'Endpoint para actualizar un rol.'
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos del rol',
           required: true,
           schema: {
               nombre: 'Rol',
               descripcion: 'Descripción del rol',
               id: 1
           }
       }
    */
    try {
        const { nombre, descripcion, id } = req.body;
        const { data, error } = await roles.update(nombre, descripcion, id);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using eliminate service with try catch for error handling
const eliminate = async (req, res) => {
    /* #swagger.tags = ['Roles']
       #swagger.description = 'Endpoint para eliminar un rol.'
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos del rol',
           required: true,
           schema: {
               id: 1
           }
       }
    */
    try {
        const { id } = req.body;
        const { error } = await roles.eliminate(id);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send('Rol eliminado');
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using getRoles service with try catch for error handling
const getRoles = async (req, res) => {
    /* #swagger.tags = ['Roles']
       #swagger.description = 'Endpoint para obtener todos los roles.'
    */
    try {
        const { data, error } = await roles.getRoles();
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using getById service with try catch for error handling
const getById = async (req, res) => {
    /* #swagger.tags = ['Roles']
       #swagger.description = 'Endpoint para obtener un rol por id.'
       #swagger.parameters['id'] = {
           in: 'path',
           description: 'Id del rol',
           required: true,
           type: 'integer'
       }
    */
    try {
        const { id } = req.params;
        const { data, error } = await roles.getById(id);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
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
    getRoles,
    getById,
};