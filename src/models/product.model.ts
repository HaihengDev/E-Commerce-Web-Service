import mongoose from 'mongoose';
import { IProduct } from '../interfaces/product.interface.ts';

const productSchema = new mongoose.Schema<IProduct>(
  {
    _id: {
      type: mongoose.Types.ObjectId,
    },
    product_id: {
      type: String,
      required: true,
    },
    product_name: {
      type: String,
      required: true,
    },
    product_imgUrl: {
      type: String,
    },
    stock: {
      type: Number,
      default: 0,
    },
    discount: {
      type: Number,
      default: 0,
    },
    price: {
      type: Number,
      required: true,
    },
    category: {
      type: String,
      required: true,
    },
    supplier: {
      type: String,
      required: true,
    },
  },
  { timestamps: true, collection: 'products' },
);

export default mongoose.model<IProduct>('Product', productSchema);
