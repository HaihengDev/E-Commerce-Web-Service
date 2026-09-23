import mongoose from 'mongoose';
import { UserRole, IUser } from '../interfaces/user.interface.ts';

const userSchema = new mongoose.Schema<IUser>(
  {
    _id: {
      type: mongoose.Types.ObjectId,
    },
    email: {
      type: String,
      required: true,
    },
    telephone: {
      type: String,
      required: true,
    },
    username: {
      type: String,
      required: true,
    },
    role: {
      type: String,
      enum: Object.values(UserRole),
      default: UserRole.User,
    },
  },
  { timestamps: true, collection: 'users' },
);

export default mongoose.model<IUser>('User', userSchema);
