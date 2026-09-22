import mongoose from 'mongoose';
import { IProduct } from '../interfaces/product.interface.ts';

const productSchema = new mongoose.Schema<IProduct>({
  _id: {
    type: mongoose.Types.ObjectId,
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
    type: mongoose.Types.ObjectId,
    required: true,
  },
});

export default mongoose.model<IProduct>('Product', productSchema);
