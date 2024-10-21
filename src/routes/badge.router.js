import { Router } from 'express';
import badgeController from '../controllers/badge.controller.js';

const router = Router();
router.post('/', badgeController.create);
router.get('/', badgeController.get);
router.get('/:id', badgeController.getById);
router.put('/:id', badgeController.update);
router.delete('/:id', badgeController.deleteById);

export default router;