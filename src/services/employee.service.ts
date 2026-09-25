import { IEmployee } from '../interfaces/employee.interface.ts';
import EmployeeRepository from '../repositories/employee.repository.ts';
import { isValidObjectId, resourceNotFound } from '../utils/helper.ts';

class EmployeeService {
  async getAll(): Promise<IEmployee[]> {
    return await EmployeeRepository.findAll();
  }

  async getById(id: string): Promise<IEmployee | null> {
    isValidObjectId(id);

    const employee = await EmployeeRepository.findById(id);

    resourceNotFound(employee);

    return employee;
  }
}

export default new EmployeeService();
