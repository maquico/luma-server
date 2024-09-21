import rewards from '../services/customRewards.service.js'

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    /* #swagger.tags = ['Custom Rewards']
       #swagger.description = 'Endpoint para registrar una recompensa.'
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos de la recompensa',
           required: true,
           schema: {
               projectId: 123456,
               iconoId: 123456,
               nombre: 'Recompensa',
               descripcion: 'Descripción de la recompensa',
               precio: 100,
               cantidad: 10,
               limite: 5
           }
       }
    */
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
    /* #swagger.tags = ['Custom Rewards']
       #swagger.description = 'Endpoint para eliminar una recompensa.'
       #swagger.parameters['obj'] = {
            in: 'body',
            description: 'Datos de la recompensa',
            required: true,
            schema: {
              id: 123456
            }
        }
    */
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
    /* #swagger.tags = ['Custom Rewards']
       #swagger.description = 'Endpoint para actualizar una recompensa.'
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos de la recompensa',
           required: true,
           schema: {
               iconoId: 123456,
               nombre: 'Recompensa',
               descripcion: 'Descripción de la recompensa',
               precio: 100,
               cantidad: 10,
               limite: 5,
               id: 123456
           }
       }   
    */
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
    /* #swagger.tags = ['Custom Rewards']
       #swagger.description = 'Endpoint para obtener todas las recompensas personalizadas.'
    */
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

//Controller using getById service with try catch for error handling
const getById = async (req, res) => {
    /* #swagger.tags = ['Custom Rewards']
       #swagger.description = 'Endpoint para obtener una recompensa por id.'
       #swagger.parameters['obj'] = {
            in: 'body',
            description: 'Datos de la recompensa',
            required: true,
            schema: {
              id: 123456
            }
        }
    */
    try {
        const { id } = req.body;
        const { data, error } = await rewards.getById(id);
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

//Controller using getByProject service with try catch for error handling
const getByProject = async (req, res) => {
    /* #swagger.tags = ['Custom Rewards']
       #swagger.description = 'Endpoint para obtener todas las recompensas de un proyecto.'
       #swagger.parameters['obj'] = {
          in: 'body',
          description: 'Datos de la recompensa',
          required: true,
          schema: {
            projectId: 123456
          }
        }
    */
    try {
        const { projectId } = req.body;
        const { data, error } = await rewards.getByProject(projectId);
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

const getByUserAndProject = async (req, res) => {
    /* #swagger.tags = ['Custom Rewards']
       #swagger.description = 'Endpoint para obtener todas las recompensas de un proyecto para un usuario en la tienda.'
       #swagger.parameters['obj'] = {
            in: 'body',
            description: 'Datos de la recompensa',
            required: true,
            schema: {
                userId: 123456,
                projectId: 123456
            }
        }
    */
    try {
        const { userId, projectId } = req.params;
        const { data, error } = await rewards.getByUserAndProject(userId, projectId);
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
    eliminate,
    update,
    getRecompensas,
    getById,
    getByProject,
    getByUserAndProject,
};