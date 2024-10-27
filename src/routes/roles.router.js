import { Router } from 'express';
import rolesController from '../controllers/roles.controller.js';

const router = Router();

router.post("/", rolesController.create);
router.put("/", rolesController.update);
router.delete("/", rolesController.eliminate);
router.get("/", rolesController.getRoles);
router.get("/:id", rolesController.getById);

export default router;