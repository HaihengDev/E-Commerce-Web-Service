const mongoose = require('mongoose');

const productSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Product name is required!'],
      unique: true,
    },
    stock: {
      type: Number,
      default: 0,
    },
    price: {
      type: Number,
      required: [true, 'Product price is required!'],
    },
    image: {
      type: String,
      required: [true, 'Product image is required!'],
    },
  },
  { timestamps: true },
);

module.exports = mongoose.model('Product', productSchema);
