import mongoose from 'mongoose';
import { IOrder } from '../interfaces/order.interface.ts';

const orderSchema = new mongoose.Schema<IOrder>(
  {
    _id: {
      type: mongoose.Types.ObjectId,
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

export default mongoose.model<IOrder>('Order', orderSchema);
