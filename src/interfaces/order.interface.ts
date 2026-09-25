import mongoose from 'mongoose';

export interface IOrderDetails {
  product_id: string;
  product_name: string;
  quantity: number;
  price: number;
}

export interface IOrder {
  _id?: mongoose.Types.ObjectId;
  user_id: string;
  orders: IOrderDetails[];
}
