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

export default {
    create,
};