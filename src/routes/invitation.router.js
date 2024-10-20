
import { Router } from 'express';
import invitationController from '../controllers/invitation.controller.js';

const router = Router();
router.post('/', invitationController.create);
router.post('/validate/', invitationController.validate);
router.post('/send/', invitationController.sendEmail);
router.get('/', invitationController.get);
router.get('/route/:token', invitationController.getInvitationRoute);
router.get('/:id', invitationController.getById);
router.get('/token/:token', invitationController.getByToken);
router.delete('/:id', invitationController.deleteById);
router.put('/:id', invitationController.update);

export default router