import { request } from 'express';
import rewards from '../services/customRewards.service.js'

// Controller using createAdmin service with try catch for error handling
const createAdmin = async (req, res) => {
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
        const { data, error } = await rewards.createAdmin(projectId, iconoId, nombre, descripcion, precio, cantidad, limite);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};


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
        const { projectId, iconoId, nombre, descripcion, precio, cantidad, limite, userId } = req.body;
        const { data, error } = await rewards.create(projectId, iconoId, nombre, descripcion, precio, cantidad, limite, userId);
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
    /* #swagger.tags = ['Custom Rewards']
       #swagger.description = 'Endpoint para eliminar una recompensa.'
       #swagger.parameters['obj'] = {
            in: 'body',
            description: 'Datos de la recompensa',
            required: true,
            schema: {
              rewardId: 123456,
              requestUserId: 'u12ms2i919al'
            }
        }
    */
    try {
        const { rewardId, requestUserId } = req.body;
        const { data, error } = await rewards.eliminate(rewardId, requestUserId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
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
               rewardId: 123456,
               requestUserId: 'u12ms2i919al'
           }
       }   
    */
    try {
        const { iconoId, nombre, descripcion, precio, cantidad, limite, rewardId, requestUserId } = req.body;
        const { data, error } = await rewards.update(iconoId,
                                                    nombre, 
                                                    descripcion, 
                                                    precio, 
                                                    cantidad, 
                                                    limite, 
                                                    rewardId, 
                                                    requestUserId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
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
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
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
         #swagger.parameters['id'] = {
            in: 'path',
            description: 'Id de la recompensa',
            required: true,
            type: 'integer'
        }
    */
    try {
        const { id } = req.params;
        const { data, error } = await rewards.getById(id);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
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
            #swagger.parameters['projectId'] = {
                in: 'path',
                description: 'Id del proyecto',
                required: true,
                type: 'integer'
            }
    */
    try {
        const { projectId } = req.params;
        const { data, error } = await rewards.getByProject(projectId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

const getByUserShop = async (req, res) => {
    /* #swagger.tags = ['Custom Rewards']
       #swagger.description = 'Endpoint para obtener todas las recompensas para un usuario en la tienda.'
            #swagger.parameters['userId'] = {
                in: 'path',
                description: 'Id del usuario',
                required: true,
                type: 'string'
            }
    */
    try {
        const { projectId, userId } = req.params;
        const { data, error } = await rewards.getByUserShop(userId, projectId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};


// Controller using buyCustomReward service with try catch for error handling
const buyCustomReward = async (req, res) => {
    /* #swagger.tags = ['Custom Rewards']
       #swagger.description = 'Endpoint para comprar una recompensa.'
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos de la compra',
           required: true,
           schema: {
               userId: 'u12ms2i919al',
               rewardId: 123456
           }
       }
    */
    try {
        const { userId, rewardId } = req.body;
        const { data, error } = await rewards.buyCustomReward(userId, rewardId);
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
    createAdmin,
    create,
    eliminate,
    update,
    getRecompensas,
    getById,
    getByProject,
    getByUserShop,
    buyCustomReward,
};