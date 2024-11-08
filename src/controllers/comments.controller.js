import comments from '../services/comments.service.js';

const create = async (req, res) => {
    /* #swagger.autoBody = false
       #swagger.tags = ['Comment']
       #swagger.description = 'Endpoint para registrar un comentario.'
       #swagger.consumes = ['application/json']
       #swagger.parameters['obj'] = {
           in: 'body',
           required: true,
           description: 'ID del usuario',
           schema: {
                userId: "uuid",
                taskId: 1,
                content: 'Este es un comentario de prueba.'
              }
            }
       }
    }
    */
    try {
        const commentObj = req.body;
        console.log(commentObj);
        const { data, error } = await comments.create(commentObj);

        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }

        return res.status(200).send(data);
    } catch (error) {
        console.log(error);
        return res.status(500).send(error);
    }
}

const get = async (req, res) => {
    /* #swagger.tags = ['Comment']
       #swagger.description = 'Endpoint para obtener todos los comentarios.'
    */
    try {
        const { data, error } = await comments.get();

        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }

        return res.status(200).send(data);
    } catch (error) {
        console.log(error);
        return res.status(500).send(error);
    }
}

const getById = async (req, res) => {
    /* #swagger.tags = ['Comment']
       #swagger.description = 'Endpoint para obtener un comentario por ID.'
       #swagger.parameters['id'] = { description: 'ID del comentario', required: true }
    */
    try {
        const id = req.params.id;
        const { data, error } = await comments.getById(id);

        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }

        return res.status(200).send(data);
    } catch (error) {
        console.log(error);
        return res.status(500).send(error);
    }
}

const getByTask = async (req, res) => {
    /* #swagger.tags = ['Comment']
       #swagger.description = 'Endpoint para obtener todos los comentarios de una tarea.'
       #swagger.parameters['taskId'] = { description: 'ID de la tarea', required: true }
    */
    try {
        const taskId = req.params.taskId;
        const { data, error } = await comments.getByTask(taskId);

        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }

        return res.status(200).send(data);
    } catch (error) {
        console.log(error);
        return res.status(500).send(error);
    }
}

const getByUser = async (req, res) => {
    /* #swagger.tags = ['Comment']
       #swagger.description = 'Endpoint para obtener todos los comentarios de un usuario.'
       #swagger.parameters['userId'] = { description: 'ID del usuario', required: true }
    */
    try {
        const userId = req.params.userId;
        const { data, error } = await comments.getByUser(userId);

        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }

        return res.status(200).send(data);
    } catch (error) {
        console.log(error);
        return res.status(500).send(error);
    }
}

const update = async (req, res) => {
    /* #swagger.tags = ['Comment']
       #swagger.description = 'Endpoint para actualizar un comentario.'
       #swagger.parameters['id'] = { description: 'ID del comentario', required: true }
       #swagger.parameters['obj'] = {
              in: 'body',
              required: true,
              description: 'ID del usuario',
              schema: {
                 userId: "uuid",
                 taskId: 1,
                 content: 'Este es un comentario de prueba.'
                  }
              }
         }
    */
    try {
        const commentId = req.params.id;
        let commentObj = req.body;
        commentObj = {
            Usuario_ID: commentObj.userId,
            Tarea_ID: commentObj.taskId,
            contenido: commentObj.content
        }
        const { data, error } = await comments.update(commentId, commentObj);

        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }

        return res.status(200).send(data);
    } catch (error) {
        console.log(error);
        return res.status(500).send(error);
    }
}

const deleteById = async (req, res) => {
    /* #swagger.tags = ['Comment']
       #swagger.description = 'Endpoint para eliminar un comentario.'
       #swagger.parameters['id'] = { description: 'ID del comentario', required: true }
    */
    try {
        const id = req.params.id;
        const { data, error } = await comments.deleteById(id);

        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }

        return res.status(200).send(data);
    } catch (error) {
        console.log(error);
        return res.status(500).send(error);
    }
}

export default { 
    create,
    get, 
    getById, 
    getByTask, 
    getByUser, 
    update, 
    deleteById,
}