import mongoose from 'mongoose';

export enum Gender {
  Male = 'Male',
  Female = 'Female',
}

export interface IEmployee {
  _id?: mongoose.Types.ObjectId;
  employee_name: string;
  employee_gender?: Gender;
  employment_date?: string;
  salary?: number;
  bonus?: number;
}
