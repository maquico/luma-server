const express = require('express');

const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Luma API running...');
})

app.listen(port, () => {
  console.log(`Luma API listening on port ${port}`);
})