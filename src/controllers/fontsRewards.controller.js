import fonts from '../services/fontsRewards.service.js'

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    /* #swagger.tags = ['Fonts']
       #swagger.description = 'Endpoint para registrar una fuente.'
       #swagger.parameters['obj'] = {
          in: 'body',
          description: 'Datos de la fuente',
          required: true,
          schema: {
              nombre: 'Fuente',
              precio: 100
          }
     }
    */
    try {
        const { nombre, precio } = req.body;
        const { data, error } = await fonts.create(nombre, precio);
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
    /* #swagger.tags = ['Fonts']
       #swagger.description = 'Endpoint para eliminar una fuente.'
       #swagger.parameters['obj'] = {
              in: 'body',
              description: 'Datos de la fuente',
              required: true,
              schema: {
              id: 123456
              }
     }
    */
    try {
        const { id } = req.body;
        const { error } = await fonts.eliminate(id);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
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
       #swagger.parameters['obj'] = {
          in: 'body',
          description: 'Datos de la fuente',
          required: true,
          schema: {
              nombre: 'Fuente',
              precio: 100,
              id: 123456
          }
       }
    */
    try {
        const { nombre, precio, id } = req.body;
        const { data, error } = await fonts.update(nombre, precio, id);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using getFuentes service with try catch for error handling
const get = async (req, res) => {
    /* #swagger.tags = ['Fonts']
       #swagger.description = 'Endpoint para obtener todas las fuentes.'
    */
    try {
        const { data, error } = await fonts.get();
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
    get,
};