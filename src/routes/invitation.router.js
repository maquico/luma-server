
import { Router } from 'express';
import invitationController from '../controllers/invitation.controller.js';

const router = Router();
router.post('/', invitationController.create);
router.post('/validate/:token', invitationController.validate);
router.post('/send/', invitationController.sendEmail);

export default router;