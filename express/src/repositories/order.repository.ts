import { IOrder } from '../interfaces/order.interface.ts';
import Order from '../models/order.model.ts';

class OrderRepository {
  async findAll(): Promise<IOrder[]> {
    return await Order.find();
  }

  async findById(id: string): Promise<IOrder | null> {
    return await Order.findById(id);
  }

  async insert(order: IOrder): Promise<IOrder | null> {
    return await Order.create(order);
  }

  async update(id: string, newOrder: IOrder): Promise<IOrder | null> {
    return await Order.findByIdAndUpdate(id, newOrder);
  }

  async delete(id: string): Promise<IOrder | null> {
    return await Order.findByIdAndDelete(id);
  }
}

export default new OrderRepository();
