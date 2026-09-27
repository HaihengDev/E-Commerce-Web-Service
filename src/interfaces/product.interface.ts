import mongoose from 'mongoose';

export interface IProduct {
  _id?: mongoose.Types.ObjectId;
  product_id: string;
  product_name: string;
  product_imgUrl?: string;
  stock?: number;
  discount?: number;
  price: number;
  category: string;
  supplier: string;
}
