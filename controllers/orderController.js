const mongoose = require('mongoose');
const Order = require('../models/orders.js');
const Product = require('../models/products.js');

const createOrder = async (req, res) => {
  try {
    const { name } = req.body;
    const quantity = req.body.quantity ?? 1;

    if (!name) {
      return res.status(400).json({
        status: 'failed',
        message: 'Name product is required!',
      });
    }

    // automatic stock update + decrease stock
    const product = await Product.findOneAndUpdate(
      {
        name: { $regex: name, $options: 'i' },
        stock: { $gte: quantity }, // 👈 only update if enough stock
      },
      { $inc: { stock: -quantity } },
      { new: true },
    );

    if (!product) {
      return res.status(400).json({
        status: 'failed',
        message: 'Product not found or insufficient stock!',
      });
    }

    const order = await Order.create({
      name: product.name,
      quantity,
      price: product.price,
    });

    res.status(200).json({
      status: 'success',
      message: 'Order is created successfully!',
      data: { order, product },
    });
  } catch (err) {
    res.status(500).json({
      status: 'failed',
      message: err.message,
    });
  }
};

const getOrders = async (req, res) => {
  try {
    const orders = await Order.find();

    res.status(200).json({
      status: 'success',
      data: orders,
    });
  } catch (err) {
    res.status(500).json({
      status: 'failed',
      message: err.message,
    });
  }
};

const getOrderById = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        status: 'failed',
        message: 'Order ID format is invalid!',
      });
    }
    const order = await Order.findById(id);

    if (!order) {
      return res.status(400).json({
        status: 'failed',
        message: 'Order is not found!',
      });
    }

    res.status(200).json({
      status: 'success',
      data: order,
    });
  } catch (err) {
    res.status(500).json({
      status: 'failed',
      message: err.message,
    });
  }
};

const updateOrder = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        status: 'failed',
        message: 'Order ID is invalid format!',
      });
    }

    if (!updateData || Object.keys(updateData).length === 0) {
      return res.status(400).json({
        status: 'failed',
        message: 'Please provide information for update!',
      });
    }

    const order = await Order.findByIdAndUpdate(id, updateData, {
      new: true,
      runValidators: true,
    });

    if (!order) {
      return res.status(404).json({
        status: 'failed',
        message: 'Failed to update order!',
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Update Order Successfully!',
      data: order,
    });
  } catch (err) {
    res.status(500).json({
      status: 'failed',
      message: err.message,
    });
  }
};

const deleteOrder = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        status: 'failed',
        message: 'Order Id format is invald!',
      });
    }

    const order = await Order.findByIdAndDelete(id);

    if (!order) {
      return res.status(400).json({
        status: 'failed',
        message: 'Order id is not found!',
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Order is deleted successfully!',
      data: order,
    });
  } catch (err) {
    res.status(500).json({
      status: 'failed',
      message: err.message,
    });
  }
};

module.exports = {
  createOrder,
  getOrders,
  getOrderById,
  updateOrder,
  deleteOrder,
};
