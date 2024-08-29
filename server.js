import express, { urlencoded, json } from 'express';
import cors from 'cors';  
import userRouter from './src/routes/user.router.js';
import sessionRouter from './src/routes/session.router.js';
import { serve, setup } from 'swagger-ui-express';
import swaggerFile from './src/configs/swagger-output.json' assert { type: "json" };

const app = express();
const port = 3000;

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

// Start server
app.listen(port, () => {
  console.log(`Luma API listening on port ${port}`);
})

