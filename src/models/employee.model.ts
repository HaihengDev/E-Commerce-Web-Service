import mongoose from 'mongoose';
import { Gender, IEmployee } from '../interfaces/employee.interface.ts';
import { counterId } from '../utils/helper.ts';

const employeeSchema = new mongoose.Schema<IEmployee>(
  {
    _id: {
      type: mongoose.Types.ObjectId,
    },
    employee_id: {
      type: String,
      required: true,
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

employeeSchema.pre('save', async function () {
  this.employee_id = await counterId('employee', 'emp');
});

export default mongoose.model<IEmployee>('Employee', employeeSchema);
