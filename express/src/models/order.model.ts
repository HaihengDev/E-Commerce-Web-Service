import mongoose from 'mongoose';
import { IOrder } from '../interfaces/order.interface.ts';
import { counterId } from '../utils/helper.ts';

const orderSchema = new mongoose.Schema<IOrder>(
  {
    _id: {
      type: mongoose.Types.ObjectId,
    },
    order_id: {
      type: String,
      required: true,
    },
    product_id: {
      type: String,
      required: true,
    },
    product_name: {
      type: String,
      required: true,
    },
    quantity: {
      type: Number,
      required: true,
    },
    price: {
      type: Number,
      required: true,
    },
    customer_id: {
      type: String,
      required: true,
    },
  },
  { timestamps: true, collection: 'orders' },
);

orderSchema.pre('save', async function () {
  this.order_id = await counterId('order', 'ord');
});

export default mongoose.model<IOrder>('Order', orderSchema);
