const { mongoose } = require('mongoose');
const Product = require('../models/products.js');

const createProduct = async (req, res) => {
  try {
    const { name, stock, price } = req.body;

    if (!name || !price) {
      return res.status(404).json({
        status: 'failed',
        message: 'Name and price for product is required!',
      });
    }

    const product = await Product.create({
      name,
      stock,
      price,
      image: req.file.filename,
    });

    res.status(201).json({
      status: 'success',
      message: 'Product is created successfully!',
      data: product,
    });
  } catch (error) {
    res.status(404).json({
      status: 'failed',
      message: error.message,
    });
  }
};

const getAllProducts = async (req, res) => {
  try {
    const products = await Product.find();

    res.status(200).json({
      status: 'success',
      result: products.length,
      data: products,
    });
  } catch (err) {
    res.status(500).json({
      status: 'failed',
      message: err.message,
    });
  }
};

const getProductById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(404).json({
        status: 'failed',
        message: 'Product id is invalid format',
      });
    }

    const products = await Product.findById(id).lean();

    if (products.length === 0) {
      return res.status(404).json({
        status: 'failed',
        message: 'Product not found!',
      });
    }

    res.status(200).json({
      status: 'success',
      result: products.length,
      data: products,
    });
  } catch (err) {
    res.status(500).json({
      status: 'failed',
      message: err.message,
    });
  }
};

const deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        status: 'failed',
        message: 'Product is is invalid format!',
      });
    }

    const product = await Product.findByIdAndDelete(id);

    if (!product) {
      return res.status(404).json({
        status: 'failed',
        message: 'Product not found!',
      });
    }

    res.status(200).json({
      status: 'success',
      data: product,
    });
  } catch (err) {
    res.status(500).json({
      status: 'failed',
      message: err.message,
    });
  }
};

const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        status: 'failed',
        message: 'Invalid id format',
      });
    }

    if (!updateData || Object.keys(updateData).length === 0) {
      return res.status(400).json({
        status: 'failed',
        message: 'Please provide at least one field of data for update',
      });
    }

    const product = await Product.findByIdAndUpdate(id, updateData, {
      new: true,
      runValidators: true,
    });

    if (!product) {
      return res.status(404).json({
        status: 'failed',
        message: 'product with this id not found!',
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Product updated successfully!',
      data: product,
    });
  } catch (err) {
    res.status(500).json({
      status: 'failed',
      message: err.message,
    });
  }
};
module.exports = {
  createProduct,
  getAllProducts,
  getProductById: async () => {},
  deleteProduct: async () => {},
  updateProduct: async () => {},
};
