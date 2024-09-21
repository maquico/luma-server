import { Router } from 'express';
import projectsController from '../controllers/projects.controller.js';

const router = Router();
router.post("/", projectsController.create);
router.get("/", projectsController.getProyectos);
router.get("/:id", projectsController.getById);
router.get("/:userId", projectsController.getByUser);

export default router;
