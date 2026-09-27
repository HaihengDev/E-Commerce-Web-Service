import mongoose from 'mongoose';
import { ICustomer } from '../interfaces/customer.interface.ts';

const customerSchema = new mongoose.Schema<ICustomer>(
  {
    _id: {
      type: mongoose.Types.ObjectId,
    },
    customer_name: {
      type: String,
      required: true,
    },
    order_count: {
      type: Number,
      default: 0,
    },
    loyalty_points: {
      type: Number,
      default: 0,
    },
    order_history: {
      type: Array<string>,
    },
  },
  { timestamps: true, collection: 'customers' },
);

export default mongoose.model<ICustomer>('Customer', customerSchema);
