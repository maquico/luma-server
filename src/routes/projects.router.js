import { Router } from 'express';
import projectsController from '../controllers/projects.controller.js';

const router = Router();
router.post("/", projectsController.create);
router.get("/", projectsController.getProyectos);
router.post("/id", projectsController.getById);
router.post("/user", projectsController.getByUser);

export default router;
