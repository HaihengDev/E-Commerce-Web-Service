import express from 'express';
import {
  createCategory,
  deleteCategory,
  readAllCategories,
  readCategoryById,
  updateCategory,
} from '../controllers/category.controller.ts';

const router = express.Router();

router.get('/', readAllCategories);
router.get('/:id', readCategoryById);
router.post('/', createCategory);
router.put('/:id', updateCategory);
router.delete('/:id', deleteCategory);

export default router;
