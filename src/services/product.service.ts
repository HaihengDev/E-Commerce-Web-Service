import ProductRepository from '../repositories/product.repository.ts';
import { IProduct } from '../interfaces/product.interface.ts';
import { isValidObejctId } from '../utils/helper.ts';

class ProductService {
  async getAll(): Promise<IProduct[]> {
    return await ProductRepository.findAll();
  }

  async getById(id: string): Promise<IProduct | null> {
    isValidObejctId(id);

    return await ProductRepository.findById(id);
  }

  async add(product: IProduct): Promise<IProduct | null> {
    return await ProductRepository.insert(product);
  }

  async update(id: string, newProduct: IProduct): Promise<IProduct | null> {
    isValidObejctId(id);

    // add logic for validate

    return await ProductRepository.update(id, newProduct);
  }

  async remove(id: string): Promise<IProduct | null> {
    isValidObejctId(id);

    return await ProductRepository.delete(id);
  }
}

export default new ProductService();
