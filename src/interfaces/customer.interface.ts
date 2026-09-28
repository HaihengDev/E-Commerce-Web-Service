import mongoose from 'mongoose';

export interface ICustomer {
  _id?: mongoose.Types.ObjectId;
  customer_id?: string;
  customer_name: string;
  order_count?: number;
  loyalty_points?: number;
  order_history?: Array<string>;
}
