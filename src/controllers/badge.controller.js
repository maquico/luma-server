import badge from '../services/badge.service.js';

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    /* #swagger.tags = ['Badge']
       #swagger.description = 'Endpoint para registrar una insignia.'
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos de la insignia',
           required: true,
           schema: {
               name: 'Badge',
               description: 'Insignia de bronce',
               categoryId: 1,
               meta: 100,
               image: 'https://example.com/image.jpg'
              }
         }
    */
    try {
        const badgeObj = req.body;
        const { data, error } = await badge.create(badgeObj);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

const get = async (req, res) => {
    /* #swagger.tags = ['Badge']
       #swagger.description = 'Endpoint para obtener todas las insignias.'
    */
    try {
        const { data, error } = await badge.get();
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

const getById = async (req, res) => {
    /* #swagger.tags = ['Badge']
       #swagger.description = 'Endpoint para obtener una insignia por ID.'
       #swagger.parameters['id'] = { description: 'ID de la insignia', required: true }
    */
    try {
        const id = req.params.id;
        const { data, error } = await badge.getById(id);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

const update = async (req, res) => {
    /* #swagger.tags = ['Badge']
       #swagger.description = 'Endpoint para actualizar una insignia.'
       #swagger.parameters['id'] = { description: 'ID de la insignia', required: true }
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos de la insignia',
           required: true,
           schema: {
               name: 'Badge',
               description: 'Insignia de plata',
               categoryId: 2,
               meta: 200,
               image: 'https://example.com/image.jpg'
              }
            }
    */
    try {
        const badgeId = req.params.id;
        const badgeObj = req.body;
        const { data, error } = await badge.update(badgeId, badgeObj);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

const deleteById = async (req, res) => {
    /* #swagger.tags = ['Badge']
       #swagger.description = 'Endpoint para eliminar una insignia por ID.'
       #swagger.parameters['id'] = { description: 'ID de la insignia', required: true }
    */
    try {
        const id = req.params.id;
        const { data, error } = await badge.deleteById(id);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

export default {
    create,
    get,
    getById,
    update,
    deleteById
}