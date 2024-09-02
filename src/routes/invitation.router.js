
import { Router } from 'express';
import invitationController from '../controllers/invitation.controller.js';

const router = Router();
router.post('/', invitationController.create);
router.post('/:token', invitationController.validate);

export default router;