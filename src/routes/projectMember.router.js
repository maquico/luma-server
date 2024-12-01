import { Router } from 'express';
import projectMemberController from '../controllers/projectMember.controller.js';

const router = Router();
router.post("/", projectMemberController.create);
router.put("/", projectMemberController.update);
router.put("/role", projectMemberController.updateRole);
router.delete("/", projectMemberController.eliminate);
router.delete("/client", projectMemberController.deleteMemberClient);
router.get("/", projectMemberController.getMiembros);
router.get("/user/:userId/project/:projectId", projectMemberController.getByUserProject);
router.get("/user/:userId", projectMemberController.getByUserId);
router.get("/project/:projectId", projectMemberController.getByProjectId);
router.get("/projects/ids/:userId", projectMemberController.getProjectsIdsByUserId);

export default router;