import { IEmployee } from '../interfaces/employee.interface.ts';
import Employee from '../models/employee.model.ts';

class EmployeeRepository {
  async findAll(): Promise<IEmployee[]> {
    return await Employee.find();
  }

  async findById(id: string): Promise<IEmployee | null> {
    return await Employee.findById(id);
  }

  async insert(employee: IEmployee): Promise<IEmployee | null> {
    return await Employee.create(employee);
  }

  async update(id: string, newEmployee: IEmployee): Promise<IEmployee | null> {
    return await Employee.findByIdAndUpdate(id, newEmployee);
  }

  async delete(id: string): Promise<IEmployee | null> {
    return await Employee.findByIdAndDelete(id);
  }
}

export default new EmployeeRepository();
