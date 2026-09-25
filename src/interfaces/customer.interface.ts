import mongoose from 'mongoose';
import { IOrderDetails } from './order.interface.ts';

export interface ICustomer {
  customer_id: mongoose.Types.ObjectId;
  customer_name: string;
  order_count: number;
  loyalty_point: number;
  order_history: IOrderDetails[];
}
