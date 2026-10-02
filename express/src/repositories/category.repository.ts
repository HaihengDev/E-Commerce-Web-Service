import { ICategory } from '../interfaces/category.interface.ts';
import Category from '../models/category.model.ts';

class CategoryRepository {
  async findAll(): Promise<ICategory[]> {
    return await Category.find();
  }

  async findById(id: string): Promise<ICategory | null> {
    return await Category.findById(id);
  }

  async insert(category: ICategory): Promise<ICategory | null> {
    return await Category.create(category);
  }

  async update(id: string, newCategory: ICategory): Promise<ICategory | null> {
    return await Category.findByIdAndUpdate(id, newCategory);
  }

  async delete(id: string): Promise<ICategory | null> {
    return await Category.findByIdAndDelete(id);
  }
}

export default new CategoryRepository();
