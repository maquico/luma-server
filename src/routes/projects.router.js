import { Router } from 'express';
import projectsController from '../controllers/projects.controller.js';

const router = Router();
router.post("/", projectsController.create);
router.get("/", projectsController.getProyectos);
router.get("/id/:id", projectsController.getById);
router.get("/user/:userId", projectsController.getByUser);
router.put("/", projectsController.update);
router.delete("/:id", projectsController.eliminate);

export default router;
