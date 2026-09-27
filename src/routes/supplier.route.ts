import express from 'express';
import {
  createSupplier,
  deleteSupplier,
  readAllSuppliers,
  readSupplierById,
  updateSupplier,
} from '../controllers/supplier.controller.ts';

const router = express.Router();

router.get('/', readAllSuppliers);
router.get('/:id', readSupplierById);
router.post('/', createSupplier);
router.put('/:id', updateSupplier);
router.delete('/:id', deleteSupplier);

export default router;
