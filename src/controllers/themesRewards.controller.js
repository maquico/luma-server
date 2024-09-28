import themes from '../services/themesRewards.service.js'

// Controller using create service with try catch for error handling
const create = async (req, res) => {
    /* #swagger.tags = ['Themes']
       #swagger.description = 'Endpoint para registrar un tema.'
         #swagger.parameters['obj'] = {
            in: 'body',
            description: 'Datos del tema',
            required: true,
            schema: {
                nombre: 'Tema',
                precio: 100,
                accentHex: '#FFFFFF',
                primaryHex: '#FFFFFF',
                secondaryHex: '#FFFFFF',
                backgroundHex: '#FFFFFF',
                textHex: '#FFFFFF'
            }
        }
  */
    try {
        const { nombre, precio, accentHex, primaryHex, secondaryHex, backgroundHex, textHex } = req.body;
        const { data, error } = await themes.create(nombre, precio, accentHex, primaryHex, secondaryHex, backgroundHex, textHex);
        if (error) {
            let statusCode;
            error.status ? statusCode = parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using eliminate service with try catch for error handling
const eliminate = async (req, res) => {
    /* #swagger.tags = ['Themes']
       #swagger.description = 'Endpoint para eliminar un tema.'
            #swagger.parameters['obj'] = {
                in: 'body',
                description: 'Datos del tema',
                required: true,
                schema: {
                    id: 123456
                }
            }
  */
    try {
        const { id } = req.body;
        const { error } = await themes.eliminate(id);
        if (error) {
            let statusCode;
            error.status ? statusCode = parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send('Tema eliminado');
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using update service with try catch for error handling
const update = async (req, res) => {
    /* #swagger.tags = ['Themes']
       #swagger.description = 'Endpoint para actualizar un tema.'
            #swagger.parameters['obj'] = {
                in: 'body',
                description: 'Datos del tema',
                required: true,
                schema: {
                    nombre: 'Tema',
                    precio: 100,
                    accentHex: '#FFFFFF',
                    primaryHex: '#FFFFFF',
                    secondaryHex: '#FFFFFF',
                    backgroundHex: '#FFFFFF',
                    textHex: '#FFFFFF',
                    id: 123456
                }
            }   
    */
    try {
        const { nombre, precio, accentHex, primaryHex, secondaryHex, backgroundHex, textHex, id } = req.body;
        const { data, error } = await themes.update(nombre, precio, accentHex, primaryHex, secondaryHex, backgroundHex, textHex, id);
        if (error) {
            let statusCode;
            error.status ? statusCode = parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
};

// Controller using getTemas service with try catch for error handling
const get = async (req, res) => {
    /* #swagger.tags = ['Themes']
       #swagger.description = 'Endpoint para obtener todos los temas.'
    */
    try {
        const { data, error } = await themes.get();
        if (error) {
            let statusCode;
            error.status ? statusCode = parseInt(error.status) : 500;
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