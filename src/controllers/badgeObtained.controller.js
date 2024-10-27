import badgeObtained from '../services/badgeObtained.service.js';

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    /* #swagger.tags = ['Badge Obtained']
       #swagger.description = 'Endpoint para registrar una insignia obtenida.'
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos de la insignia obtenida',
           required: true,
           schema: {
               userId: 'abc123',
               badgeId: 123456
           }
       }
    */
    try {
        const badgeObtainedObj = req.body;
        const { data, error } = await badgeObtained.create(badgeObtainedObj);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using get service with try catch for error handling
const get = async (req, res) => {
    /* #swagger.tags = ['Badge Obtained']
       #swagger.description = 'Endpoint para obtener todas las insignias obtenidas.'
    */
    try {
        const { data, error } = await badgeObtained.get();
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using getByUserId service with try catch for error handling
const getByUser = async (req, res) => {
    /* #swagger.tags = ['Badge Obtained']
       #swagger.description = 'Endpoint para obtener todas las insignias obtenidas por un usuario.'
            #swagger.parameters['userId'] = {
                in: 'path',
                description: 'Id del usuario',
                required: true,
                type: 'string'
            }
    */
    try {
        const userId = req.params.userId;
        const { data, error } = await badgeObtained.getByUser(userId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using getByBadgeId service with try catch for error handling
const getByBadge = async (req, res) => {
    /* #swagger.tags = ['Badge Obtained']
       #swagger.description = 'Endpoint para obtener todas las insignias obtenidas por una insignia.'
            #swagger.parameters['badgeId'] = {
                in: 'path',
                description: 'Id de la insignia',
                required: true,
                type: 'string'
            }
    */
    try {
        const badgeId = req.params.badgeId;
        const { data, error } = await badgeObtained.getByBadge(badgeId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using getByUserAndBadge service with try catch for error handling
const getByUserAndBadge = async (req, res) => {
    /* #swagger.tags = ['Badge Obtained']
       #swagger.description = 'Endpoint para obtener una insignia obtenida por usuario e insignia.'
            #swagger.parameters['userId'] = {
                in: 'path',
                description: 'Id del usuario',
                required: true,
                type: 'string'
            }
            #swagger.parameters['badgeId'] = {
                in: 'path',
                description: 'Id de la insignia',
                required: true,
                type: 'string'
            }
    */
    try {
        const userId = req.params.userId;
        const badgeId = req.params.badgeId;
        const { data, error } = await badgeObtained.getByUserAndBadge(userId, badgeId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Delete by user id and badge id
const deleteByUserAndBadge = async (req, res) => {
    /* #swagger.tags = ['Badge Obtained']
       #swagger.description = 'Endpoint para eliminar una insignia obtenida por usuario e insignia.'
            #swagger.parameters['userId'] = {
                in: 'path',
                description: 'Id del usuario',
                required: true,
                type: 'string'
            }
            #swagger.parameters['badgeId'] = {
                in: 'path',
                description: 'Id de la insignia',
                required: true,
                type: 'string'
            }
    */
    try {
        const userId = req.params.userId;
        const badgeId = req.params.badgeId;
        const { data, error } = await badgeObtained.deleteByUserAndBadge(userId, badgeId);
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
    getByUser, 
    getByBadge, 
    getByUserAndBadge,
    deleteByUserAndBadge,
};

