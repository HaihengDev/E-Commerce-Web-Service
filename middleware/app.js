const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const productRoutes = require('../routes/productRoutes.js');
const orderRoutes = require('../routes/orderRoutes.js');
require('dotenv').config();
const multer = require('multer');

const app = express();

app.use(
  cors({
    origin: 'http://localhost:5173',
  }),
);

app.use(morgan('dev'));
app.use(express.json());

app.use('/uploads', express.static('uploads'));

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname),
});
const upload = multer({ storage });

// Routes
app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);

module.exports = app;
