import { z } from 'zod';

import { IProduct } from '../interfaces/product.interface.ts';
import { isValidObjectId, resourceNotFound } from '../utils/helper.ts';
import { appError } from '../exception/appError.ts';

import ProductRepository from '../repositories/product.repository.ts';

const productSchema = z.object({
  product_id: z
    .string({
      message: 'Product Id must be string',
    })
    .trim()
    .min(1, { message: 'Product Id is required.' }),
  product_name: z
    .string({
      message: 'Product Name must be string',
    })
    .trim()
    .min(1, { message: 'Product Name is required' }),
  stock: z.number({ message: 'Product stock must be numeric.' }),
  discount: z.number({ message: 'Product discount must be numeric' }),
  price: z.number({ message: 'Product price must be number.' }),
  category: z.string({ message: 'Product category must be string' }).trim(),
  supplier: z.string({ message: 'Product supplier must be string.' }).trim(),
});

class ProductService {
  async getAll(): Promise<IProduct[]> {
    return await ProductRepository.findAll();
  }

  async getById(id: string): Promise<IProduct | null> {
    isValidObjectId(id);

    return await ProductRepository.findById(id);
  }

  async add(product: IProduct): Promise<IProduct | null> {
    const result = productSchema.safeParse(product);

    if (!result.success) {
      throw new appError(400, result.error.issues[0].message);
    }

    return await ProductRepository.insert(product);
  }

  async update(id: string, newProduct: IProduct): Promise<IProduct | null> {
    isValidObjectId(id);

    const product = await this.getById(id);

    resourceNotFound(product);

    const newProductData: IProduct = {
      ...product,
      ...newProduct,
    };

    return await ProductRepository.update(id, newProductData);
  }

  async remove(id: string): Promise<IProduct | null> {
    isValidObjectId(id);

    const product = await this.getById(id);

    resourceNotFound(product);

    return await ProductRepository.delete(id);
  }
}

export default new ProductService();
