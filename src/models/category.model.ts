import mongoose from 'mongoose';
import { ICategory } from '../interfaces/category.interface.ts';

const categorySchema = new mongoose.Schema<ICategory>(
  {
    _id: {
      type: mongoose.Types.ObjectId,
    },
    category_name: {
      type: String,
      required: true,
    },
    category_imgUrl: {
      type: String,
    },
    product_length: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true, collection: 'categories' },
);

export default mongoose.model<ICategory>('Category', categorySchema);
