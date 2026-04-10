const app = require('./middleware/app.js');
const mongoose = require('mongoose');

mongoose
  .connect(process.env.MONGO_URL)
  .then(() => console.log('Database is connected successfully!'))
  .catch((err) => console.log(err));

app.listen(8000, () => console.log('Server running on port 8000'));
