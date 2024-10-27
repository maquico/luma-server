import { decode } from 'base64-arraybuffer';
import supabaseConfig from "../configs/supabase.js";

const { supabase } = supabaseConfig;

// Tiempo en segundos para 1 año (365 días)
const oneYearInSeconds = 365 * 24 * 60 * 60; // 31,536,000 segundos

// Mapa de caracteres a reemplazar
const replaceMap = {
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
    'Á': 'A', 'É': 'E', 'Í': 'I', 'Ó': 'O', 'Ú': 'U',
    'ñ': 'n', 'Ñ': 'N',
   
};

// Función para sanear el nombre del archivo
const sanitizeFileName = (fileName) => {
    // Reemplaza caracteres acentuados
    let sanitized = fileName.replace(/[áéíóúÁÉÍÓÚñÑ]/g, (match) => replaceMap[match]);
    // Reemplaza caracteres no permitidos
    sanitized = sanitized.replace(/[\/\\\?*\:<>"|]/g, "_"); // Reemplaza caracteres no permitidos
    return sanitized;
};

// Servicio para subir fotos
const uploadFile = async (fileBase64, fileName, mimeType, filePath, bucketName, upsert=false) => {
    try {
        // Sanear el nombre del archivo
        fileName = sanitizeFileName(fileName);

        const fullFilePath = filePath + fileName;

        // Convertir base64 a ArrayBuffer usando 'base64-arraybuffer'
        const fileData = decode(fileBase64);

        // Subir la imagen al bucket
        const { data, error } = await supabase
            .storage
            .from(bucketName)
            .upload(fullFilePath, fileData, {
                contentType: mimeType,
                cacheControl: '3600',
                upsert: upsert,
            });

        if (error) {
            console.log('Error subiendo la imagen al bucket:', error);
            return { success: false, error };
        }
        else{
            console.log('Imagen subida al bucket:', data);
        }

        // Generar la URL firmada válida por 1 año
        const { data: signedUrlData, error: signedUrlError } = await supabase
            .storage
            .from(bucketName)
            .createSignedUrl(fullFilePath, oneYearInSeconds);

        if (signedUrlError) {
            console.log('Error generando URL firmada:', signedUrlError);
            return { success: false, error: signedUrlError };
        }
        else{
            console.log('URL firmada generada:', signedUrlData);
        }
        // Devolver la URL firmada
        const signedUrl = signedUrlData.signedUrl;
        return { signedUrl, success: true };
    } catch (error) {
        console.error('Error al subir la foto:', error.message);
        return { success: false, message: error.message };
    }
};

export default uploadFile;