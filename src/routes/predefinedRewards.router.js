
import { Router } from 'express';
import predefinedRewardsController from '../controllers/predefinedRewards.controller.js';

const router = Router();
router.get('/:userId', predefinedRewardsController.getByUserId);
router.post('/', predefinedRewardsController.buyPredefinedReward);

export default router;