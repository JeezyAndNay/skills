const express = require('express');
const app = express();
app.use(express.json());

app.post('/run', (req, res) => {
  const input = req.body || {};
  res.json({ success: true, result: input });
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Template Node skill running on ${port}`));
