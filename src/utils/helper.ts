import mongoose from 'mongoose';
import { appError } from '../exception/appError.ts';

export const isValidObejctId = (id: string) => {
  if (!mongoose.Types.ObjectId.isValid(id)) {
    throw new appError(400, 'Invalid id format.');
  }
};
