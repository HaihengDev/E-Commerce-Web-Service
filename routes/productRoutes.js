const express = require('express');
const multer = require('multer');
const {
  createProduct,
  getAllProducts,
  getProductById,
  deleteProduct,
  updateProduct,
} = require('../controllers/productController.js');

const router = express.Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // <-- save image to folder name uploads
  },

  filename: (req, file, cb) => {
    cb(null, Date.now() + '.png', file.originalname);
  },
});

const upload = multer({ storage });

router
  .route('/')
  .post(upload.single('image'), createProduct)
  .get(getAllProducts);
router
  .route('/:id')
  .get(getProductById)
  .delete(deleteProduct)
  .put(updateProduct);

module.exports = router;
