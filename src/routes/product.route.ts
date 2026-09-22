import express from 'express';
import {
  createProduct,
  deleteProduct,
  readAllProducts,
  readProductById,
  updateProduct,
} from '../controllers/product.controller.ts';

const router = express.Router();

router.get('/', readAllProducts);
router.get('/:id', readProductById);
router.post('/', createProduct);
router.put('/:id', updateProduct);
router.delete('/:id', deleteProduct);

export default router;
