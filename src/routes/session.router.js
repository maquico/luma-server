import { Router } from 'express';
import sessionRouter from '../controllers/session.controller.js';

const router = Router();
router.post('/', sessionRouter.login);

export default router;