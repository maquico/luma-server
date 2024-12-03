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

const getByProjectIdClient = async (req, res) => {
    /* #swagger.tags = ['Task']
       #swagger.description = 'Endpoint para obtener todas las tareas de un proyecto.'
       #swagger.parameters['id'] = { description: 'ID del proyecto', required: true }
    */
    try {
        const projectId = req.params.id;
        const { data, error } = await task.getByProjectId(projectId, '*, Proyectos(nombre)', true);
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
    /* #swagger.tags = ['Admin / Task']
       #swagger.description = 'Endpoint para obtener todas las tareas de un proyecto.'
       #swagger.parameters['id'] = { description: 'ID del proyecto', required: true }
    */
    try {
        const projectId = req.params.id;
        const { data, error } = await task.getByProjectId(projectId, '*, Proyectos(nombre)', false);
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
            console.log("Error getting tags by project ID: ");
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
    /* #swagger.tags = ['Task']
       #swagger.description = 'Endpoint to update the status of a task.'
       #swagger.parameters['id'] = {
           in: 'path',
           type: 'integer',
           required: true,
           description: 'ID of the task'
       }
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos de la tarea',
           required: true,
           schema: {
                projectId: 1,
                newStatusId: 1,
                userId: 'UUID'
           }
       }
    */
    try {
        const { id } = req.params;
        const taskId = id;
        const { projectId, newStatusId, userId } = req.body;

        const { data, error } = await task.updateTaskStatus(taskId, projectId, newStatusId, userId);

        if (error) {
            return res.status(error.status || 500).send(error.message);
        }

        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

const deleteById = async (req, res) => {
    /* #swagger.tags = ['Admin / Task']
       #swagger.description = 'Endpoint para eliminar una tarea.'
       #swagger.parameters['id'] = { description: 'ID de la tarea', required: true }
       #swagger.parameters['userid'] = { description: 'ID del usuario', required: true }
       #swagger.parameters['projectid'] = { description: 'ID del proyecto', required: true }
    */
    try {
        const taskId = req.params.id;
        const userid = req.params.userid;
        const projectid = req.params.projectid;

        const { data, error } = await task.deleteById(taskId, userid, projectid);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

const approvedTasksByProject = async (req, res) => {
    /* #swagger.tags = ['Task']
       #swagger.description = 'Endpoint to get approved tasks by project. Count or details'
       #swagger.parameters['id'] = { description: 'ID of the project', required: true }
       #swagger.parameters['count'] = { description: 'If true, returns just the count of the tasks', required: false, default: true }
    */
    try {
        const projectId = req.params.id;
        const count = req.query.count || true;
        const { data, error } = await task.approvedTasksByProject(projectId, count);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}


// Controller using updateByRole service with try-catch for error handling
const updateByRole = async (req, res) => {
    /* #swagger.tags = ['Task']
       #swagger.description = 'Endpoint para actualizar una tarea según el rol del usuario.'
       #swagger.parameters['id'] = {
           in: 'path',
           type: 'string',
           required: true,
           description: 'ID of the user'
       }
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos de la tarea',
           required: true,
           schema: {
               Proyecto_ID: 1,
               Task_ID: 1,
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
        const taskObj = req.body; // El objeto de tarea recibido del cuerpo de la solicitud
        const userId = req.params.id; // El ID del usuario extraído de los parámetros de la URL

        // Usamos la función updateByRole del servicio con el objeto de tarea y el ID de usuario
        const { data, error } = await task.updateByRole(taskObj, userId);

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
    getByProjectIdClient,
    getByProjectId,
    getTagsByProjectId,
    update,
    updateTaskStatus,
    deleteById,
    approvedTasksByProject,
    updateByRole
};