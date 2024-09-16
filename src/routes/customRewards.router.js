import { Router } from 'express';
import customRewardsController from '../controllers/customRewards.controller.js';

const router = Router();
router.post("/", customRewardsController.create);
router.delete("/", customRewardsController.eliminate);
router.put("/", customRewardsController.update);
router.get("/", customRewardsController.getRecompensas);
router.get("/:userId/:projectId", customRewardsController.getByUserAndProject);
router.post("/id", customRewardsController.getById);
router.post("/project", customRewardsController.getByProject);


export default router;
