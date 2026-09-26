import { z } from 'zod';

import { isValidObjectId, resourceNotFound } from '../utils/helper.ts';
import { IOrder } from '../interfaces/order.interface.ts';
import { appError } from '../exception/appError.ts';

import OrderRepository from '../repositories/order.repository.ts';

const orderSchema = z.object({
  product_id: z.string({ message: 'Product id must be string' }).trim(),
  product_name: z.string({ message: 'Product name must be string' }).trim(),
  quantity: z
    .number({ message: 'Quantity must be number.' })
    .min(1, 'Quantity must be atleast 1.'),
  price: z
    .number({
      message: 'Price must be number.',
    })
    .min(1, 'Price must be at least 1.'),
});

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

  async add(order: IOrder) {
    const result = orderSchema.safeParse(order);

    if (!result.success) {
      throw new appError(400, result.error.issues[0].message);
    }

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
