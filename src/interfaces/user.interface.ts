import mongoose from 'mongoose';

export enum UserRole {
  Admin = 'ADMIN',
  User = 'USER',
}

export interface IUser {
  _id?: mongoose.Types.ObjectId;
  email: string;
  telephone: string;
  username: string;
  password: string;
  role?: UserRole;
}
