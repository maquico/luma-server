import { Router } from 'express';
import commentsController from '../controllers/comments.controller.js';

const router = Router();

router.post('/', commentsController.create);
router.get('/', commentsController.get);
router.get('/:id', commentsController.getById);
router.get('/task/:taskId', commentsController.getByTask);
router.get('/user/:userId', commentsController.getByUser);
router.get('/task-client/:taskId', commentsController.getByTaskClient);
router.put('/:id', commentsController.update);
router.delete('/:id', commentsController.deleteById);

export default router;