import { Router } from 'express';
import taskController from '../controllers/task.controller.js';

const router = Router();
router.post('/', taskController.create);

export default router;