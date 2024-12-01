import icon from '../services/icon.service.js';
import uploadFile from '../utils/uploadFiles.js';

const create = async (req, res) => {
    /* #swagger.autoBody = false
       #swagger.tags = ['Icon']
       #swagger.description = 'Endpoint para registrar un icono.'
       #swagger.consumes = ['multipart/form-data']
       #swagger.parameters['image'] = {
           in: 'formData',
           type: 'file',
           required: false,
           description: 'Imagen del icono',
           name: 'image'
       }
       #swagger.parameters['name'] = {
           in: 'formData',
           type: 'string',
           required: true,
           description: 'Nombre del icono'
       }
    */
    try {
        let imageSignedUrl = null;
        const iconImage = req.file; // Use req.file for file uploads
        if (iconImage) {
            // Log the file details for debugging
            console.log('File received:', iconImage);

            // Extract file name and type
            const fileName = iconImage.originalname;
            const mimeType = iconImage.mimetype;
            const fileBuffer = iconImage.buffer.toString('base64'); 

            // Define the file path and bucket name
            const filePath = 'icons/';
            const bucketName = 'luma-assets';

            // Upload the file using the uploadFile function
            const { signedUrl, success, error: uploadError } = await uploadFile(fileBuffer, fileName, mimeType, filePath, bucketName);

            if (!success) {
                return res.status(500).send({ message: 'Error uploading file', uploadError });
            }
            imageSignedUrl = signedUrl;
        }

        // Extract other form data from req.body
        const { name } = req.body;

        // Create the icon object
        const iconObj = {
            name: name,
            image: imageSignedUrl
        };

        const { data, error } = await icon.create(iconObj);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

const get = async (req, res) => {
    /* #swagger.tags = ['Icon']
       #swagger.description = 'Endpoint para obtener todos los iconos'
    */
    try {
        const { data, error } = await icon.get();
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

const getById = async (req, res) => {
    /* #swagger.tags = ['Icon']
       #swagger.description = 'Endpoint para obtener un icono por ID.'
       #swagger.parameters['id'] = { description: 'ID del icono', required: true }
    */
    try {
        const id = req.params.id;
        const { data, error } = await icon.getById(id);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

const update = async (req, res) => {
    /* 
       #swagger.autoBody = false
       #swagger.tags = ['Icon']
       #swagger.description = 'Endpoint para actualizar un icono.'
       #swagger.consumes = ['multipart/form-data']
       #swagger.parameters['id'] = { description: 'ID del icono', required: true }
       #swagger.parameters['image'] = {
           in: 'formData',
           type: 'file',
           required: false,
           description: 'Imagen de la insignia',
           name: 'image'
       }
       #swagger.parameters['name'] = {
           in: 'formData',
           type: 'string',
           required: false,
           description: 'Nombre del icono'
       }
    */
    try {
        const iconId = req.params.id;
        const iconImage = req.file; // Use req.file for file uploads
        let imageSignedUrl = null;

        if (iconImage) {
            // Log the file details for debugging
            console.log('File received:', iconImage);

            // Extract file name and type
            const fileName = `${iconId}-${iconImage.originalname}`;
            const mimeType = iconImage.mimetype;
            const fileBuffer = iconImage.buffer.toString('base64');

            // Define the file path and bucket name
            const filePath = 'icons/';
            const bucketName = 'luma-assets';

            // Upload the file using the uploadFile function
            const { signedUrl, success, error: uploadError } = await uploadFile(fileBuffer, fileName, mimeType, filePath, bucketName);

            if (!success) {
                return res.status(500).send({ message: 'Error uploading file', uploadError });
            }
            imageSignedUrl = signedUrl;
        }

        const updateFields = {};
        if (req.body.name) updateFields.nombre = req.body.name;
        if (imageSignedUrl) updateFields.foto = imageSignedUrl;

        const { data, error } = await icon.update(iconId, updateFields);

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
    get,
    getById,
    update,
}