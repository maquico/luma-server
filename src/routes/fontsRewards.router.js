import { Router } from 'express';
import fontsRewardsController from '../controllers/fontsRewards.controller.js';

const router = Router();
router.post("/", fontsRewardsController.create);
router.delete("/", fontsRewardsController.eliminate);
router.put("/", fontsRewardsController.update);
router.get("/", fontsRewardsController.getFuentes);

export default router;