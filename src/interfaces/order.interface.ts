import mongoose from 'mongoose';

export interface IOrder {
  _id?: mongoose.Types.ObjectId;
  order_id: string;
  product_id: string;
  product_name: string;
  quantity: number;
  price: number;
  customer_id: string;
}
