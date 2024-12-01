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
import session from 'express-session';
import cookieParser from 'cookie-parser';
import path from 'path';

const __dirname = path.dirname(new URL(import.meta.url).pathname);

const swaggerFile = JSON.parse(fs.readFileSync('./src/configs/swagger-output.json', 'utf8'));

const PORT = process.env.PORT || 3000;

const protectRoute = (req, res, next) => {
  console.log(req.session);
  if (!req.session || !req.session.adminUser) {
    return res.status(401).json({ message: 'Unauthorized: No session found' });
  }

  // Optionally, check for additional admin privileges
  if (!req.session.adminUser.isAdmin) {
    return res.status(403).json({ message: 'Forbidden: Admin access required' });
  }

  next();
};

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
      return { email: user[0].correo, isAdmin: true };
    }
    else {
      console.log(`User ${user[0].correo} is not an admin`);
      return null;
    }
  }
}

const start = async () => {
  const app = express();

  app.use('/assets', express.static('./assets'));
  // Middleware for parsing cookies
  app.use(cookieParser());
  

  // Load AdminJS and session store
  const { admin, sessionStore } = await adminConfig.initializeAdminJS();

  // Configure session middleware
  app.use(
    session({
      store: sessionStore,
      resave: false,
      saveUninitialized: false,
      secret: 'sessionsecret', // Match with AdminJS
      cookie: {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production', // Use secure cookies in production
        maxAge: 24 * 60 * 60 * 1000, // 1 day expiration
      },
    })
  );

  // Swagger documentation (protected)
  app.use('/doc', protectRoute, serve, setup(swaggerFile));

  // AdminJS router
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
      resave: false,
      saveUninitialized: false,
      secret: 'sessionsecret',
      cookie: {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
      },
    }
  );
  app.use(admin.options.rootPath, adminRouter);

  // Other middleware
  app.use(cors());
  app.use(urlencoded({ extended: true }));
  app.use(json());

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

  app.get('/', (req, res) => res.redirect(admin.options.rootPath));

  app.listen(PORT, () => {
    console.log(`AdminJS started on http://${process.env.HOST}${admin.options.rootPath}`);
  });
};

start();


