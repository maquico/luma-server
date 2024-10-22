import { Router } from 'express';
import badgeObtainedController from '../controllers/badgeObtained.controller.js';

const router = Router();
router.post('/', badgeObtainedController.create);
router.get('/', badgeObtainedController.get);
router.get('/user/:userId', badgeObtainedController.getByUser);
router.get('/badge/:badgeId', badgeObtainedController.getByBadge);
router.get('/:userId/:badgeId', badgeObtainedController.getByUserAndBadge);
router.delete('/:userId/:badgeId', badgeObtainedController.deleteByUserAndBadge);

export default router;