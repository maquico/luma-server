import { Router } from 'express';
import customRewardsController from '../controllers/customRewards.controller.js';

const router = Router();
router.post("/", customRewardsController.create);
router.delete("/", customRewardsController.eliminate);
router.put("/", customRewardsController.update);
router.get("/", customRewardsController.getRecompensas);
router.get("user/:userId/project/:projectId", customRewardsController.getByUserAndProject);
router.get("user/:id", customRewardsController.getById);
router.get("project/:projectId", customRewardsController.getByProject);


export default router;
