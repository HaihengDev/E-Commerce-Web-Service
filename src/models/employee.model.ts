import mongoose from 'mongoose';
import { Gender, IEmployee } from '../interfaces/employee.interface.ts';

const employeeSchema = new mongoose.Schema<IEmployee>(
  {
    _id: {
      type: mongoose.Types.ObjectId,
    },
    employee_name: {
      type: String,
      required: true,
    },
    employee_gender: {
      type: String,
      enum: Object.values(Gender),
      default: Gender.Male,
    },
    employment_date: {
      type: String,
      required: true,
    },
    salary: {
      type: Number,
      required: true,
    },
    bonus: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true, collection: 'employees' },
);

export default mongoose.model<IEmployee>('Employee', employeeSchema);
