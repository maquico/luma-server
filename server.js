const express = require('express');
const userRouter = require('./src/routes/user.router');
const swaggerUI = require('swagger-ui-express');
const swaggerFile = require('./swagger-output.json');

const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Luma API running...');
})

app.use('/doc', swaggerUI.serve, swaggerUI.setup(swaggerFile));

app.use('/user', userRouter);

app.listen(port, () => {
  console.log(`Luma API listening on port ${port}`);
})

