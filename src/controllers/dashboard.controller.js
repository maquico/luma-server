import dashboard from '../services/dashboard.service.js'

// Controller using obtenerRankingGemas service with try catch for error handling
const obtenerRankingGemas = async (req, res) => {
    /* #swagger.tags = ['Dashboard']
       #swagger.description = 'Endpoint para obtener el ranking de miembros por gemas.'
       #swagger.parameters['projectId'] = {
                in: 'path',
                description: 'ID del proyecto',
                required: true,
                type: 'integer'
            }
    */
    try {
        const { projectId } = req.params;
        const ranking = await dashboard.obtenerRankingGemas(projectId);
        return res.status(200).send(ranking);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using obtenerConteoTareas service with try catch for error handling
const obtenerConteoTareas = async (req, res) => {
    /* #swagger.tags = ['Dashboard']
       #swagger.description = 'Endpoint para obtener el conteo de tareas por estado.'
       #swagger.parameters['projectId'] = {
                in: 'path',
                description: 'ID del proyecto',
                required: true,
                type: 'integer'
            }
    */
    try {
        const { projectId } = req.params;
        const conteoTareas = await dashboard.obtenerConteoTareas(projectId);
        return res.status(200).send(conteoTareas);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using obtenerTareasPendientesUsuario services with try catch for error handling
const obtenerTareasPendientesUsuario = async (req, res) => {
    /* #swagger.tags = ['Dashboard']
       #swagger.description = 'Endpoint para obtener las tareas pendientes de un usuario.'
       #swagger.parameters['projectId'] = {
                in: 'path',
                description: 'ID del proyecto',
                required: true,
                type: 'integer'
            }
        #swagger.parameters['userId'] = {
                in: 'path',
                description: 'ID del usuario',
                required: true,
                type: 'string'
            }
    */
    try {
        const { projectId, userId } = req.params;
        const tareasPendientes = await dashboard.obtenerTareasPendientesUsuario(projectId, userId);
        return res.status(200).send(tareasPendientes);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using obtenerTareasAprobadasPorUsuario services with try catch for error handling
const obtenerTareasAprobadasPorUsuario = async (req, res) => {
    /* #swagger.tags = ['Dashboard']
       #swagger.description = 'Endpoint para obtener las tareas aprobadas por usuario.'
       #swagger.parameters['projectId'] = {
                in: 'path',
                description: 'ID del proyecto',
                required: true,
                type: 'integer'
            }
    */
    try {
        const { projectId } = req.params;
        const tareasAprobadas = await dashboard.obtenerTareasAprobadasPorUsuario(projectId);
        return res.status(200).send(tareasAprobadas);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

export default {
    obtenerRankingGemas,
    obtenerConteoTareas,
    obtenerTareasPendientesUsuario,
    obtenerTareasAprobadasPorUsuario,
};