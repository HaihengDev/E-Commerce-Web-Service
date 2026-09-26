import { IEmployee } from '../interfaces/employee.interface.ts';
import Employee from '../models/employee.model.ts';

class EmployeeRepository {
  async findAll() {
    return await Employee.find();
  }

  async findById(id: string) {
    return await Employee.findById(id);
  }

  async insert(employee: IEmployee) {
    return await Employee.create(employee);
  }

  async update(id: string, newEmployee: IEmployee) {
    return await Employee.findByIdAndUpdate(id, newEmployee);
  }

  async delete(id: string) {
    return await Employee.findByIdAndDelete(id);
  }
}

export default new EmployeeRepository();
