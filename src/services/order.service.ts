import { isValidObjectId, resourceNotFound } from '../utils/helper.ts';
import { IOrder } from '../interfaces/order.interface.ts';
import OrderRepository from '../repositories/order.repository.ts';

class OrderService {
  async getAll(): Promise<IOrder[]> {
    return await OrderRepository.findAll();
  }

  async getById(id: string): Promise<IOrder | null> {
    isValidObjectId(id);

    const order = await OrderRepository.findById(id);

    resourceNotFound(order);

    return order;
  }

  async add(order: IOrder): Promise<IOrder | null> {
    // add some logic for decrease stock in product

    return await OrderRepository.insert(order);
  }

  async update(id: string, newOrder: IOrder): Promise<IOrder | null> {
    isValidObjectId(id);

    // --> logic for count stock and price connect with product

    return await OrderRepository.update(id, newOrder);
  }

  async remove(id: string): Promise<IOrder | null> {
    return await OrderRepository.delete(id);
  }
}

export default new OrderService();
