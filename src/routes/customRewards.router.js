import { Router } from 'express';
import customRewardsController from '../controllers/customRewards.controller.js';

const router = Router();
router.post("/", customRewardsController.create);
router.delete("/", customRewardsController.eliminate);
router.put("/", customRewardsController.update);
router.get("/", customRewardsController.getRecompensas);
router.get("/:userId/:projectId", customRewardsController.getByUserAndProject);
router.get("/:id", customRewardsController.getById);
router.get("/:projectId", customRewardsController.getByProject);


export default router;
