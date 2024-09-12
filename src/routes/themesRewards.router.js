import { Router } from 'express';
import themesRewardsController from '../controllers/themesRewards.controller.js';

const router = Router();
router.post("/", themesRewardsController.create);
router.delete("/", themesRewardsController.eliminate);
router.put("/", themesRewardsController.update);
router.get("/", themesRewardsController.getTemas);

export default router;