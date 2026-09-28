import mongoose from 'mongoose';
import { ICustomer } from '../interfaces/customer.interface.ts';
import { counterId } from '../utils/helper.ts';

const customerSchema = new mongoose.Schema<ICustomer>(
  {
    _id: {
      type: mongoose.Types.ObjectId,
    },
    customer_id: {
      type: String,
      required: true,
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

customerSchema.pre('save', async function () {
  this.customer_id = await counterId('customer', 'cus');
});

export default mongoose.model<ICustomer>('Customer', customerSchema);
