import { ICustomer } from '../interfaces/customer.interface.ts';
import CustomerRepository from '../repositories/customer.repository.ts';
import { isValidObjectId, resourceNotFound } from '../utils/helper.ts';

class CustomerService {
  async getAll(): Promise<ICustomer[]> {
    return await CustomerRepository.findAll();
  }

  async getById(id: string) {
    isValidObjectId(id);

    const customer = await CustomerRepository.findById(id);

    resourceNotFound(customer);

    return customer;
  }

  async create(customer: ICustomer): Promise<ICustomer | null> {
    // --> add logic for customer input

    return await CustomerRepository.insert(customer);
  }

  async remove(id: string): Promise<ICustomer | null> {
    return await CustomerRepository.delete(id);
  }
}

export default new CustomerService();
