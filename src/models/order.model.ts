import mongoose from 'mongoose';
import { IOrder, IOrderDetails } from '../interfaces/order.interface.ts';

const orderDetailsSchema = new mongoose.Schema<IOrderDetails>(
  {
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
  },
  { _id: false },
);

const orderSchema = new mongoose.Schema<IOrder>(
  {
    _id: {
      type: mongoose.Types.ObjectId,
    },
    customer_id: {
      type: String,
      required: true,
    },
    employee_id: {
      type: String,
      required: true,
    },
    orders: {
      type: [orderDetailsSchema],
      required: true,
    },
  },
  { timestamps: true, collection: 'orders' },
);

export default mongoose.model<IOrder>('Order', orderSchema);
