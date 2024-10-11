import task from '../services/task.service.js';

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    /* #swagger.tags = ['Task']
       #swagger.description = 'Endpoint para registrar una tarea.'
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos de la tarea',
           required: true,
           schema: {
               projectId: 1,
               name: 'Task',
               priority: 1,
               time: 120,
               startDate: '2021-09-01',
               endDate: '2021-09-02',
               userId: 'UUID',
               isCritical: false,
               cost: 100,
               budget: 200,
               description: 'Task description',
               tags: 'tag1,tag2'
           }
       }
    */
    try {
        const taskObj = req.body;
        const { data, error } = await task.create(taskObj);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

const get = async (req, res) => {
    /* #swagger.tags = ['Admin / Task']
       #swagger.description = 'Endpoint para obtener todas las tareas.'
    */
    try {
        const { data, error } = await task.get();
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

const getById = async (req, res) => {
    /* #swagger.tags = ['Task']
       #swagger.description = 'Endpoint para obtener una tarea por ID.'
       #swagger.parameters['id'] = { description: 'ID de la tarea', required: true }
    */
    try {
        const taskId = req.params.id;
        const { data, error } = await task.getById(taskId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

const getByProjectId = async (req, res) => {
    /* #swagger.tags = ['Task']
       #swagger.description = 'Endpoint para obtener todas las tareas de un proyecto.'
       #swagger.parameters['id'] = { description: 'ID del proyecto', required: true }
    */
    try {
        const projectId = req.params.id;
        const { data, error } = await task.getByProjectId(projectId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

const getTagsByProjectId = async (req, res) => {
    /* #swagger.tags = ['Task']
       #swagger.description = 'Endpoint para obtener las etiquetas de un proyecto.'
       #swagger.parameters['id'] = { description: 'ID del proyecto', required: true }
    */
    try {
        const projectId = req.params.id;
        const { data, error } = await task.getTagsByProjectId(projectId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

const update = async (req, res) => {
    /* #swagger.tags = ['Admin / Task']
       #swagger.description = 'Endpoint para actualizar una tarea.'
       #swagger.parameters['id'] = { description: 'ID de la tarea', required: true }
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos de la tarea',
           required: true,
           schema: {
               Proyecto_ID: 1,
               nombre: 'Task',
               prioridad: 1,
               tiempo: 120,
               fechaInicio: '2021-09-01',
               fechaFin: '2021-09-02',
               Usuario_ID: 'UUID',
               esCritica: false,
               gastos: 100,
               presupuesto: 200,
               descripcion: 'Task description',
               etiquetas: 'tag1,tag2'
           }
       }
    */
    try {
        const taskId = req.params.id;
        const taskObj = req.body;
        const { data, error } = await task.update(taskId, taskObj);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

const updateTaskStatus = async (req, res) => {
    /* #swagger.tags = ['Admin / Task']
       #swagger.description = 'Endpoint para actualizar el estado de una tarea.'
       #swagger.parameters['id'] = { description: 'ID de la tarea', required: true }
       #swagger.parameters['status'] = { description: 'Estado de la tarea', required: true }
    */
    try {
        const taskId = req.params.id;
        const taskStatus = req.body.status;
        const { data, error } = await task.updateTaskStatus(taskId, taskStatus);
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
    /* #swagger.tags = ['Admin / Task']
       #swagger.description = 'Endpoint para eliminar una tarea.'
       #swagger.parameters['id'] = { description: 'ID de la tarea', required: true }
    */
    try {
        const taskId = req.params.id;
        const { data, error } = await task.deleteById(taskId);
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
    get,
    getById,
    getByProjectId,
    getTagsByProjectId,
    update,
    deleteById,
};