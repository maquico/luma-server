
import { Router } from 'express';
import predefinedRewardsController from '../controllers/predefinedRewards.controller.js';

const router = Router();
router.get('/:userId', predefinedRewardsController.getByUserId);

export default router;