import badgeCategory from '../services/badgeCategory.service.js';

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    /* #swagger.tags = ['Badge Category']
       #swagger.description = 'Endpoint para registrar una categoría de insignia.'
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos de la categoría de insignia',
           required: true,
           schema: {
               name: 'Badge Category',
               comparativeField: 'experiencePoints',
           }
       }
    */
    try {
        const badgeCategoryObj = req.body;
        const { data, error } = await badgeCategory.create(badgeCategoryObj);
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
    /* #swagger.tags = ['Badge Category']
       #swagger.description = 'Endpoint para obtener todas las categorías de insignias.'
    */
    try {
        const { data, error } = await badgeCategory.get();
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
    /* #swagger.tags = ['Badge Category']
       #swagger.description = 'Endpoint para obtener una categoría de insignia por ID.'
       #swagger.parameters['id'] = { description: 'ID de la categoría de insignia', required: true }
    */
    try {
        const id = req.params.id;
        const { data, error } = await badgeCategory.getById(id);
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
    /* #swagger.tags = ['Badge Category']
       #swagger.description = 'Endpoint para actualizar una categoría de insignia.'
       #swagger.parameters['id'] = { description: 'ID de la categoría de insignia', required: true }
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos de la categoría de insignia',
           required: true,
           schema: {
               nombre: 'Badge Category',
               campoComparativo: 'experiencePoints',
           }
       }
    */
    try {
        const id = req.params.id;
        const badgeCategoryObj = req.body;
        const { data, error } = await badgeCategory.update(id, badgeCategoryObj);
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
    /* #swagger.tags = ['Badge Category']
       #swagger.description = 'Endpoint para eliminar una categoría de insignia por ID.'
       #swagger.parameters['id'] = { description: 'ID de la categoría de insignia', required: true }
    */
    try {
        const id = req.params.id;
        const { data, error } = await badgeCategory.deleteById(id);
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
    deleteById,
};