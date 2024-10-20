import { Router } from 'express';
import taskController from '../controllers/task.controller.js';

const router = Router();
router.post('/', taskController.create);
router.get('/', taskController.get);
router.get('/:id', taskController.getById);
router.get('/project/:id', taskController.getByProjectId);
router.get('/tags/:id', taskController.getTagsByProjectId);
router.put('/:id', taskController.update);
router.delete('/:id', taskController.deleteById);
router.put('/status/:id', taskController.updateTaskStatus);


export default router;