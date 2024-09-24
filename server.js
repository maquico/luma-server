import express, { urlencoded, json } from 'express';
import cors from 'cors';
import * as fs from 'fs';
import userRouter from './src/routes/user.router.js';
import sessionRouter from './src/routes/session.router.js';
import invitationRouter from './src/routes/invitation.router.js';
import projectsRouter from './src/routes/projects.router.js';
import fontsRouter from './src/routes/fontsRewards.router.js';
import themesRouter from './src/routes/themesRewards.router.js';
import rewardsRouter from './src/routes/customRewards.router.js';
import predefinedRewardsRouter from './src/routes/predefinedRewards.router.js';
import { serve, setup } from 'swagger-ui-express';

const swaggerFile = JSON.parse(fs.readFileSync('./src/configs/swagger-output.json', 'utf8'));

const app = express();
const port = process.env.PORT || 3000;

// Express middlewares
app.use(cors());
app.use(urlencoded({ extended: true }));
app.use(json());

// Base route
app.get('/', (req, res) => {
  res.send('Luma API running...');
})

// Swagger documentation
app.use('/doc', serve, setup(swaggerFile));

// API routes
app.use('/api/user', userRouter);
app.use('/api/session', sessionRouter);
app.use('/api/invitation', invitationRouter);
app.use('/api/projects', projectsRouter);
app.use('/api/fonts', fontsRouter);
app.use('/api/themes', themesRouter);
app.use('/api/rewards', rewardsRouter);
app.use('/api/rewards/predefined', predefinedRewardsRouter);

// Start server
app.listen(port, () => {
  console.log(`Luma API listening on port ${port}`);
})

