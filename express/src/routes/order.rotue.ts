import express from 'express';
import {
  createOrder,
  deleteOrder,
  readAllOrders,
  readOrderById,
  updateOrder,
} from '../controllers/order.controller.ts';

const router = express.Router();

router.get('/', readAllOrders);
router.get('/:id', readOrderById);
router.post('/', createOrder);
router.put('/:id', updateOrder);
router.delete('/:id', deleteOrder);

export default router;
