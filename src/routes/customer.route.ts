import express from 'express';
import {
  readAllCustomers,
  readCustomerById,
} from '../controllers/customer.controller.ts';

const router = express.Router();

router.get('/', readAllCustomers);
router.get('/:id', readCustomerById);

export default router;
