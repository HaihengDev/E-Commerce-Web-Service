import mongoose from 'mongoose';

export interface ICategory {
  _id?: mongoose.Types.ObjectId;
  category_name: string;
  category_imgUrl?: string;
  product_length?: number;
}
