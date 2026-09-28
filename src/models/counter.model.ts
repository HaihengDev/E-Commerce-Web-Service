import mongoose from 'mongoose';
import { ICounter } from '../interfaces/counter.interface.ts';

const counterSchema = new mongoose.Schema<ICounter>({
  name: {
    type: String,
    required: true,
    unique: true,
  },
  sequence: {
    type: Number,
    default: 0,
  },
});

export default mongoose.model<ICounter>('Counter', counterSchema);
