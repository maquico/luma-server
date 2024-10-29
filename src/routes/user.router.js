import { Router } from 'express';
import userController from '../controllers/user.controller.js';
import multer from 'multer';

// Configure multer for file uploads
const storage = multer.memoryStorage(); // Store files in memory
const upload = multer({ 
    storage: storage,
    limits: { fileSize: 6 * 1024 * 1024 } // Limit to 6MB
  });

const router = Router();
router.post('/', userController.create);
router.post('/otp/send', userController.sendOtp);
router.post('/otp/verify', userController.verifyOtp);
router.put('/password/reset', userController.resetPassword);
router.get('/admin/:id', userController.getByIdAdmin);
router.get('/admin', userController.getAdmin); 
router.get('/:id', userController.getById); 
router.get('/', userController.getClient);
router.put('/custom/:id', userController.updateCustomUser);
router.put('/auth/:id', userController.updateAuthUser);
router.put('/email/reset', userController.resetEmail);
router.put('/', upload.single('image'), userController.update);
router.delete('/:id', userController.deleteById);

export default router;