import express, { urlencoded, json } from 'express';
import cors from 'cors';
import * as fs from 'fs';
import AdminJSExpress from '@adminjs/express';
import adminConfig from './src/configs/admin.js';
import sessionService from './src/services/session.service.js';
import userService from './src/services/user.service.js';
import userRouter from './src/routes/user.router.js';
import invitationRouter from './src/routes/invitation.router.js';
import projectsRouter from './src/routes/projects.router.js';
import fontsRouter from './src/routes/fontsRewards.router.js';
import themesRouter from './src/routes/themesRewards.router.js';
import rewardsRouter from './src/routes/customRewards.router.js';
import predefinedRewardsRouter from './src/routes/predefinedRewards.router.js';
import projectMemberRouter from './src/routes/projectMember.router.js';
import taskRouter from './src/routes/task.router.js';
import badgeCategoryRouter from './src/routes/badgeCategory.router.js';
import badgeRouter from './src/routes/badge.router.js';
import badgeObtainedRouter from './src/routes/badgeObtained.router.js';
import rolesRouter from './src/routes/roles.router.js';
import commentsRouter from './src/routes/comments.router.js';
import dashboardRouter from './src/routes/dashboard.router.js';
import { serve, setup } from 'swagger-ui-express';

const swaggerFile = JSON.parse(fs.readFileSync('./src/configs/swagger-output.json', 'utf8'));

const PORT = process.env.PORT || 3000;

const authenticate = async (email, password) => {
  const { data, error } = await sessionService.create(email, password);
  if (error) {
    console.log("Error on admin login (auth schema table): ", error);
    return null;
  }

  if (data) {
    const { data: user, error: userError} = await userService.getByEmail(email);
    if (userError) {
      console.log("Error on admin login (public schema table): ", error);
      return null;
    }

    if (user[0].esAdmin){
      console.log(`Admin ${user[0].correo} logged in`);
      return { email: user[0].correo, password: user[0].contraseña };
    }
    else {
      console.log(`User ${user[0].correo} is not an admin`);
      return null;
    }
  }
}

// Start server
const start = async () => {
  const app = express();
  
  // Swagger documentation
  app.use('/doc', serve, setup(swaggerFile));
  
  // API routes
  app.use('/api/user', userRouter);
  app.use('/api/invitation', invitationRouter);
  app.use('/api/projects', projectsRouter);
  app.use('/api/fonts', fontsRouter);
  app.use('/api/themes', themesRouter);
  app.use('/api/rewards', rewardsRouter);
  app.use('/api/rewards-predefined', predefinedRewardsRouter);
  app.use('/api/member', projectMemberRouter);
  app.use('/api/task', taskRouter);
  app.use('/api/badge-category', badgeCategoryRouter);
  app.use('/api/badge', badgeRouter);
  app.use('/api/badge-obtained', badgeObtainedRouter);
  app.use('/api/roles', rolesRouter);
  app.use('/api/comments', commentsRouter);
  app.use('/api/dashboard', dashboardRouter);

  const { admin, sessionStore } = await adminConfig.initializeAdminJS();

  if (process.env.NODE_ENV === 'production') await admin.initialize();
  else admin.watch();

  const adminRouter = AdminJSExpress.buildAuthenticatedRouter(
    admin,
    {
      authenticate,
      cookieName: 'adminjs',
      cookiePassword: 'sessionsecret',
    },
    null,
    {
      store: sessionStore,
      resave: true,
      saveUninitialized: true,
      secret: 'sessionsecret',
      cookie: {
        httpOnly: process.env.NODE_ENV === 'production',
        secure: process.env.NODE_ENV === 'production',
      },
      name: 'adminjs',
    }
  )
  app.use(admin.options.rootPath, adminRouter);
  app.get('/', (req, res) => res.redirect(admin.options.rootPath));
  
  // Express middlewares
  app.use(cors());
  app.use(urlencoded({ extended: true }));
  app.use(json());

  app.listen(PORT, () => {
    console.log(`AdminJS started on http://localhost:${PORT}${admin.options.rootPath}`)
  })
}

start()

