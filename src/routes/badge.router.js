import { Router } from 'express';
import multer from 'multer';
import badgeController from '../controllers/badge.controller.js';

const router = Router();

// Configure multer for file uploads
const storage = multer.memoryStorage(); // Store files in memory
const upload = multer({ 
    storage: storage,
    limits: { fileSize: 6 * 1024 * 1024 } // Limit to 6MB
  });

router.post('/', upload.single('image'), badgeController.create);
router.get('/', badgeController.get);
router.get('/:id', badgeController.getById);
router.get('/id-client/:id', badgeController.getByIdClient);
router.put('/:id', upload.single('image'), badgeController.update);
router.delete('/:id', badgeController.deleteById);

export default router;