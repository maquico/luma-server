const express = require('express');
const cors = require('cors');  
const userRouter = require('./src/routes/user.router');
const sessionRouter = require('./src/routes/session.router');
const swaggerUI = require('swagger-ui-express');
const swaggerFile = require('./src/configs/swagger-output.json');

const app = express();
const port = 3000;

// Express middlewares
app.use(cors());
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Base route
app.get('/', (req, res) => {
  res.send('Luma API running...');
})

// Swagger documentation
app.use('/doc', swaggerUI.serve, swaggerUI.setup(swaggerFile));

// API routes
app.use('/api/user', userRouter);

app.use('/api/session', sessionRouter);

// Start server
app.listen(port, () => {
  console.log(`Luma API listening on port ${port}`);
})

