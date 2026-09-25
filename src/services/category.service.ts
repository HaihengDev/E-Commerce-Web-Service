import { ICategory } from '../interfaces/category.interface.ts';
import { isValidObjectId } from '../utils/helper.ts';
import CategoryRepository from '../repositories/category.repository.ts';

class CategoryService {
  async getAll(): Promise<ICategory[]> {
    return await CategoryRepository.findAll();
  }

  async getById(id: string): Promise<ICategory | null> {
    isValidObjectId(id);

    return await CategoryRepository.findById(id);
  }

  async add(category: ICategory): Promise<ICategory | null> {
    // --> add logic for file convert image and update product count

    return await CategoryRepository.insert(category);
  }

  async update(id: string, newCategory: ICategory): Promise<ICategory | null> {
    isValidObjectId(id);
    // --> add logic for update validation

    return await CategoryRepository.update(id, newCategory);
  }

  async remove(id: string) {
    return await CategoryRepository.delete(id);
  }
}

export default new CategoryService();
