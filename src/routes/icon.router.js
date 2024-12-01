import { Router } from 'express';
import multer from 'multer';
import iconController from '../controllers/icon.controller.js';

const router = Router();

// Configure multer for file uploads
const storage = multer.memoryStorage(); // Store files in memory
const upload = multer({ 
    storage: storage,
    limits: { fileSize: 6 * 1024 * 1024 } // Limit to 6MB
  });

router.post('/', upload.single('image'), iconController.create);
router.get('/', iconController.get);
router.get('/:id', iconController.getById);
router.put('/:id', upload.single('image'), iconController.update);

export default router;