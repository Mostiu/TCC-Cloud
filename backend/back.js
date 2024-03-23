const express = require('express');
const app = express();
const path = require('path');
const port = 8081;

app.use(express.static(path.join(__dirname, 'public')));

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});