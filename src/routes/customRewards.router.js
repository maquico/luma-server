import { Router } from 'express';
import customRewardsController from '../controllers/customRewards.controller.js';

const router = Router();
router.post("/", customRewardsController.create);
router.delete("/", customRewardsController.eliminate);
router.put("/", customRewardsController.update);
router.get("/", customRewardsController.getRecompensas);
router.get("/user/:userId/", customRewardsController.getByUserShop);
router.get("/:id", customRewardsController.getById);
router.get("/project/:projectId", customRewardsController.getByProject);


export default router;
