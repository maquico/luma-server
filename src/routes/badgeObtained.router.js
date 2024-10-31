import { Router } from 'express';
import badgeObtainedController from '../controllers/badgeObtained.controller.js';

const router = Router();
router.post('/', badgeObtainedController.create);
router.get('/', badgeObtainedController.get);
router.get('/user', badgeObtainedController.getByUser); 
router.get('/user-client', badgeObtainedController.getByUserClient);
router.get('/badge', badgeObtainedController.getByBadge); 
router.get('/user-badge', badgeObtainedController.getByUserAndBadge); 
router.delete('/:userId/:badgeId', badgeObtainedController.deleteByUserAndBadge);

export default router;