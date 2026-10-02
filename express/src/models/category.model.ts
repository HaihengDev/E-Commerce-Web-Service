import mongoose from 'mongoose';
import { ICategory } from '../interfaces/category.interface.ts';
import { counterId } from '../utils/helper.ts';

const categorySchema = new mongoose.Schema<ICategory>(
  {
    _id: {
      type: mongoose.Types.ObjectId,
    },
    category_id: {
      type: String,
      required: true,
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

categorySchema.pre('save', async function () {
  this.category_id = await counterId('category', 'cat');
});

export default mongoose.model<ICategory>('Category', categorySchema);
