import { ICustomer } from '../interfaces/customer.interface.ts';
import Customer from '../models/customer.model.ts';

class CustomerRepository {
  async findAll(): Promise<ICustomer[]> {
    return await Customer.find();
  }

  async findById(id: string): Promise<ICustomer | null> {
    return await Customer.findById(id);
  }

  async insert(customer: ICustomer): Promise<ICustomer | null> {
    return await Customer.create(customer);
  }

  async delete(id: string): Promise<ICustomer | null> {
    return await Customer.findByIdAndDelete(id);
  }
}

export default new CustomerRepository();
