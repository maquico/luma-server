const express = require('express');
const userRouter = require('./src/routes/user.router');

const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Luma API running...');
})

app.use('/user', userRouter);

app.listen(port, () => {
  console.log(`Luma API listening on port ${port}`);
})

