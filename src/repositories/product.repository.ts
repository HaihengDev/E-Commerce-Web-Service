import Product from '../models/product.model.ts';
import { IProduct } from '../interfaces/product.interface.ts';

class ProductRepository {
  async findAll(): Promise<IProduct[]> {
    return await Product.find();
  }

  async findById(id: string): Promise<IProduct | null> {
    return await Product.findById(id);
  }

  async insert(product: IProduct): Promise<IProduct | null> {
    return await Product.create(product);
  }

  async update(id: string, newProduct: IProduct): Promise<IProduct | null> {
    return await Product.findByIdAndUpdate(id, newProduct);
  }

  async delete(id: string): Promise<IProduct | null> {
    return await Product.findByIdAndDelete(id);
  }

  async increaseStock(id: string): Promise<IProduct | null> {
    return await Product.findOneAndUpdate(
      { _id: id, stock: { $gt: 0 } },
      { $inc: { stock: 1 } },
      { new: true },
    );
  }

  async decreaseStock(id: string): Promise<IProduct | null> {
    return await Product.findOneAndUpdate(
      { _id: id, stock: { $gt: 0 } },
      { $inc: { stock: -1 } },
      { new: true },
    );
  }
}

export default new ProductRepository();
