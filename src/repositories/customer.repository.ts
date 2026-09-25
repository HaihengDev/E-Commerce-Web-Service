import { ICustomer } from '../interfaces/customer.interface.ts';
import Customer from '../models/customer.model.ts';

class CustomerRepository {
  async findAll() {
    return await Customer.find();
  }

  async findById(id: string) {
    return await Customer.findById(id);
  }

  async insert(customer: ICustomer) {
    return await Customer.create(customer);
  }

  async delete(id: string) {
    return await Customer.findByIdAndDelete(id);
  }
}

export default new CustomerRepository();
