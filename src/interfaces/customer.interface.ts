import mongoose from 'mongoose';
import { IOrderDetails } from './order.interface.ts';

export interface ICustomer {
  _id?: mongoose.Types.ObjectId;
  customer_name: string;
  order_count: number;
  loyalty_points: number;
  order_history: IOrderDetails[];
}
