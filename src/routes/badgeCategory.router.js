import { Router } from 'express';
import badgeCategoryController from '../controllers/badgeCategory.controller.js';

const router = Router();
router.post('/', badgeCategoryController.create);
router.get('/', badgeCategoryController.get);
router.get('/:id', badgeCategoryController.getById);
router.put('/:id', badgeCategoryController.update);
router.delete('/:id', badgeCategoryController.deleteById);

export default router;
