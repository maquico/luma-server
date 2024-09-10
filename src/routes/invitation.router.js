
import { Router } from 'express';
import invitationController from '../controllers/invitation.controller.js';

const router = Router();
router.post('/', invitationController.create);
router.post('/validate/', invitationController.validate);
router.post('/send/', invitationController.sendEmail);
router.get('/route/:token', invitationController.getInvitationRoute);

export default router;