import { Router } from "express";
import dashboardController from "../controllers/dashboard.controller.js";

const router = Router();
router.get("/ranking/:projectId", dashboardController.obtenerRankingGemas);
router.get("/conteoTareas/:projectId", dashboardController.obtenerConteoTareas);
router.get("/tareasPendientes/:userId/:projectId", dashboardController.obtenerTareasPendientesUsuario);
router.get("/tareasAprobadas/:projectId", dashboardController.obtenerTareasAprobadasPorUsuario);

export default router;