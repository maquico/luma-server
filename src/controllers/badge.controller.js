import badge from '../services/badge.service.js';
import uploadFile from '../utils/uploadFiles.js';

const create = async (req, res) => {
    /* #swagger.autoBody = false
       #swagger.tags = ['Badge']
       #swagger.description = 'Endpoint para registrar una insignia.'
       #swagger.consumes = ['multipart/form-data']
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
           required: true,
           description: 'Nombre de la insignia'
       }
       #swagger.parameters['description'] = {
           in: 'formData',
           type: 'string',
           required: true,
           description: 'Descripción de la insignia'
       }
       #swagger.parameters['categoryId'] = {
           in: 'formData',
           type: 'integer',
           required: true,
           description: 'ID de la categoría'
       }
       #swagger.parameters['meta'] = {
           in: 'formData',
           type: 'integer',
           required: true,
           description: 'Meta de la insignia'
       }
    */
    try {
        let imageSignedUrl = null;
        const badgeImage = req.file; // Use req.file for file uploads
        if (badgeImage) {
            // Log the file details for debugging
            console.log('File received:', badgeImage);

            // Extract file name and type
            const fileName = badgeImage.originalname;
            const mimeType = badgeImage.mimetype;
            const fileBuffer = badgeImage.buffer.toString('base64'); 

            // Define the file path and bucket name
            const filePath = 'badges/';
            const bucketName = 'luma-assets';

            // Upload the file using the uploadFile function
            const { signedUrl, success, error: uploadError } = await uploadFile(fileBuffer, fileName, mimeType, filePath, bucketName);

            if (!success) {
                return res.status(500).send({ message: 'Error uploading file', uploadError });
            }
            imageSignedUrl = signedUrl;
        }

        // Extract other form data from req.body
        const { name, description, categoryId, meta } = req.body;

        // Create the badge object
        const badgeObj = {
            name,
            description,
            categoryId: parseInt(categoryId, 10),
            meta: parseInt(meta, 10),
            image: imageSignedUrl
        };

        const { data, error } = await badge.create(badgeObj);
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
    /* #swagger.tags = ['Badge']
       #swagger.description = 'Endpoint para obtener todas las insignias.'
    */
    try {
        const { data, error } = await badge.get();
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
    /* #swagger.tags = ['Badge']
       #swagger.description = 'Endpoint para obtener una insignia por ID.'
       #swagger.parameters['id'] = { description: 'ID de la insignia', required: true }
    */
    try {
        const id = req.params.id;
        const { data, error } = await badge.getById(id);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

const getByIdClient = async (req, res) => {
    /* #swagger.tags = ['Badge']
       #swagger.description = 'Endpoint para obtener una insignia por ID para el cliente (frontend).'
       #swagger.parameters['id'] = { description: 'ID de la insignia', required: true }
    */
    try {
        const id = req.params.id;
        const columns = 'Insignia_ID, nombre, descripcion, foto';
        const { data, error } = await badge.getById(id, columns);
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
    /* #swagger.tags = ['Badge']
       #swagger.description = 'Endpoint para actualizar una insignia.'
       #swagger.parameters['id'] = { description: 'ID de la insignia', required: true }
       #swagger.parameters['obj'] = {
           in: 'body',
           description: 'Datos de la insignia',
           required: true,
           schema: {
               nombre: 'Badge',
               descripcion: 'Insignia de plata',
               Insignia_Cat_ID: 2,
               meta: 200,
               foto: 'https://example.com/image.jpg'
              }
            }
    */
    try {
        const badgeId = req.params.id;
        const badgeObj = req.body;
        const { data, error } = await badge.update(badgeId, badgeObj);
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
    /* #swagger.tags = ['Badge']
       #swagger.description = 'Endpoint para eliminar una insignia por ID.'
       #swagger.parameters['id'] = { description: 'ID de la insignia', required: true }
    */
    try {
        const id = req.params.id;
        const { data, error } = await badge.deleteById(id);
        if (error) {
            const statusCode = error.status ? parseInt(error.status) : 500;
            return res.status(statusCode).send(error.message);
        }
        return res.status(200).send(data);
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

const uploadBadgeImage = async (req, res) => {
    /* #swagger.tags = ['Badge']
       #swagger.description = 'Endpoint para subir una imagen de insignia.'
       #swagger.consumes = ['multipart/form-data']
       #swagger.parameters['image'] = {
           in: 'formData',
           type: 'file',
           required: true,
           description: 'Imagen de la insignia',
           name: 'image'
       }
    */
    try {
        const badgeImage = req.file; // Use req.file for file uploads
        if (!badgeImage) {
            return res.status(400).send({ message: 'No file uploaded' });
        }

        // Log the file details for debugging
        console.log('File received:', badgeImage);

        // Extract file name and type
        const fileName = badgeImage.originalname;
        const mimeType = badgeImage.mimetype;
        const fileBuffer = badgeImage.buffer.toString('base64'); // Convert buffer to base64 string

        // Define the file path and bucket name
        const filePath = 'icons/';
        const bucketName = 'luma-assets';

        // Upload the file using the uploadFile function
        const { signedUrl, success, error } = await uploadFile(fileBuffer, fileName, mimeType, filePath, bucketName);

        if (!success) {
            return res.status(500).send({ message: 'Error uploading file', error });
        }

        return res.status(200).send({ message: 'Image uploaded successfully', imageUrl: signedUrl });
    } catch (error) {
        return res.status(500).send(error.message);
    }
}

export default {
    create,
    get,
    getById,
    getByIdClient,
    update,
    deleteById,
    uploadBadgeImage,
}