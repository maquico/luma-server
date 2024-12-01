import member from '../services/projectMember.service.js'

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    /* #swagger.tags = ['Admin / Project Members']
         #swagger.description = 'Endpoint para agregar un miembro a un proyecto.'
            #swagger.parameters['obj'] = {
                in: 'body',
                description: 'Datos del miembro',
                required: true,
                schema: {
                    projectId: 1,
                    userId: 'u12ms2i919al',
                    rolId: 1
                }
            }
    */
    try {
        const { projectId, userId, rolId } = req.body;
        const { data, error } = await member.create(projectId, userId, rolId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(201).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

//Controller using update service with try catch for error handling
const update = async (req, res) => {
    /* #swagger.tags = ['Admin / Project Members']
         #swagger.description = 'Endpoint para actualizar un miembro de un proyecto.'
            #swagger.parameters['obj'] = {
                in: 'body',
                description: 'Datos del miembro',
                required: true,
                schema: {
                    projectId: 1,
                    userId: 'u12ms2i919al',
                    rolId: 1,
                    gemas: 10
                }
            }
    */
    try {
        const { projectId, userId, rolId, gemas } = req.body;
        const { data, error } = await member.update(projectId, userId, rolId, gemas);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

//Controller using update service with try catch for error handling
const updateRole = async (req, res) => {
    /* #swagger.tags = ['Project Members']
         #swagger.description = 'Endpoint para actualizar el rol de un miembro de un proyecto.'
            #swagger.parameters['obj'] = {
                in: 'body',
                description: 'Datos del miembro',
                required: true,
                schema: {
                    projectId: 1,
                    userId: 'u12ms2i919al',
                    roleId: 1,
                    requestUserId: 'u12ms2i919al'
                }
            }
    */
    try {
        const { projectId, userId, roleId, requestUserId } = req.body;
        const { data, error } = await member.updateMemberRole(projectId, userId, roleId, requestUserId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

// Controller using eliminate service with try catch for error handling
const eliminate = async (req, res) => {
    /* #swagger.tags = ['Admin / Project Members']
       #swagger.description = 'Endpoint para eliminar un miembro de un proyecto (admin)'
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos del miembro',
           required: true,
           schema: {
               projectId: 1,
               userId: 'u12ms2i919al'
           }
       }
    */
    try {
        const { projectId, userId } = req.body;
        const { data, error } = await member.eliminate(projectId, userId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

const deleteMemberClient = async (req, res) => {
    /* #swagger.tags = ['Project Members']
       #swagger.description = 'Endpoint para eliminar un miembro de un proyecto. Para ser consumido por el cliente'
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos del miembro',
           required: true,
           schema: {
               projectId: 1,
               userId: 'u12ms2i919al',
               requestUserId: 'u12ms2i919al'
           }
       }
    */
    try {
        const { projectId, userId, requestUserId } = req.body;
        const { data, error } = await member.deleteMemberClient(projectId, userId, requestUserId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

// Controller using getMiembros service with try catch for error handling
const getMiembros = async (req, res) => {
    /* #swagger.tags = ['Project Members']
         #swagger.description = 'Endpoint para obtener todos los miembros de un proyecto.'
    */
    try {
        const { data, error } = await member.getMiembros();
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

// Controller using getByUserProject service with try catch for error handling
const getByUserProject = async (req, res) => {
    /* #swagger.tags = ['Project Members']
         #swagger.description = 'Endpoint para obtener un miembro de un proyecto.'
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
        const { data, error } = await member.getByUserProject(userId, projectId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

// Controller using getByUserId service with try catch for error handling
const getByUserId = async (req, res) => {
    /* #swagger.tags = ['Project Members']
         #swagger.description = 'Endpoint para obtener todos los miembros de un proyecto por id de usuario.'
            #swagger.parameters['userId'] = {
                in: 'path',
                description: 'ID del usuario',
                required: true,
                type: 'string'
            }
    */
    try {
        const { userId } = req.params;
        const { data, error } = await member.getByUserId(userId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

const getProjectsIdsByUserId = async (req, res) => {
    /* #swagger.tags = ['Project Members']
         #swagger.description = 'Endpoint para obtener todos los proyectos de un usuario por id de usuario.'
            #swagger.parameters['userId'] = {
                in: 'path',
                description: 'ID del usuario',
                required: true,
                type: 'string'
            }
    */
    try {
        const { userId } = req.params;
        const { data, error } = await member.getProjectsIdsByUserId(userId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

// Controller using getByProjectId service with try catch for error handling
const getByProjectId = async (req, res) => {
    /* #swagger.tags = ['Project Members']
         #swagger.description = 'Endpoint para obtener todos los miembros de un proyecto por id de proyecto.'
            #swagger.parameters['projectId'] = {
                in: 'path',
                description: 'ID del proyecto',
                required: true,
                type: 'integer'
            }
    */
    try {
        const { projectId } = req.params;
        const { data, error } = await member.getByProjectId(projectId);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

export default {
    create,
    update,
    updateRole,
    eliminate,
    deleteMemberClient,
    getMiembros,
    getByUserProject,
    getByUserId,
    getByProjectId,
    getProjectsIdsByUserId
}