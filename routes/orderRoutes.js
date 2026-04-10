const express = require('express');
const {
  createOrder,
  getOrders,
  getOrderById,
  updateOrder,
  deleteOrder,
} = require('../controllers/orderController.js');

const router = express.Router();

router.route('/').post(createOrder).get(getOrders);
router.route('/:id').get(getOrderById).put(updateOrder).delete(deleteOrder);

module.exports = router;
