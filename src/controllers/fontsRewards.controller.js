import fonts from '../services/fontsRewards.service.js'

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    /* #swagger.tags = ['Fonts']
       #swagger.description = 'Endpoint para registrar una fuente.'
    */
    try {
        const { nombre, precio } = req.body;
        const { data, error } = await fonts.create(nombre, precio);
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
    /* #swagger.tags = ['Fonts']
       #swagger.description = 'Endpoint para eliminar una fuente.'
    */
    try {
        const { id } = req.body;
        const { error } = await fonts.eliminate(id);
        if (error) {
            const errorStatusCode = parseInt(error.status, 10)
            console.log(errorStatusCode);
            return res.status(errorStatusCode).send(error.message);
        }
        return res.status(200).send('Fuente eliminada');
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using update service with try catch for error handling
const update = async (req, res) => {
    /* #swagger.tags = ['Fonts']
       #swagger.description = 'Endpoint para actualizar una fuente.'
    */
    try {
        const { nombre, precio, id } = req.body;
        const { data, error } = await fonts.update(nombre, precio, id);
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

// Controller using getFuentes service with try catch for error handling
const getFuentes = async (req, res) => {
    /* #swagger.tags = ['Fonts']
       #swagger.description = 'Endpoint para obtener todas las fuentes.'
    */
    try {
        const { data, error } = await fonts.getFuentes();
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
    getFuentes,
};