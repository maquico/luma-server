import { Router } from 'express';
import multer from 'multer';
import badgeController from '../controllers/badge.controller.js';

const router = Router();

// Configure multer for file uploads
const storage = multer.memoryStorage(); // Store files in memory
const upload = multer({ storage: storage });

// Define the route with multer middleware
router.post('/upload', upload.single('image'), badgeController.uploadBadgeImage);

router.post('/', badgeController.create);
router.get('/', badgeController.get);
router.get('/:id', badgeController.getById);
router.put('/:id', badgeController.update);
router.delete('/:id', badgeController.deleteById);

export default router;