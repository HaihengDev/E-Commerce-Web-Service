import mongoose from 'mongoose';

export enum UserRole {
  Admin = 'ADMIN',
  Employee = 'EMPLOYEE',
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

export interface IAuthResponse {
  user: IUser;
  token: string;
}

export interface ILogin {
  email: string;
  password: string;
}
