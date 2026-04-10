const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Product name is required!'],
    },
    quantity: {
      type: Number,
      default: 1,
    },
    price: {
      type: Number,
      required: [true, 'Product price is required!'],
    },
    total: Number,
  },
  { timestamps: true, collection: 'orders' },
);

orderSchema.pre('save', function () {
  this.total = this.quantity * this.price;
});

orderSchema.pre('findOneAndUpdate', async function () {
  const update = this.getUpdate();

  if (update.quantity || update.price) {
    const docToUpdate = await this.model.findOne(this.getQuery());

    const quantity = update.quantity ?? docToUpdate.quantity;
    const price = update.price ?? docToUpdate.price;

    update.total = price * quantity;
  }
});

module.exports = mongoose.model('Order', orderSchema);
