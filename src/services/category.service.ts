import { z } from 'zod';

import { ICategory } from '../interfaces/category.interface.ts';
import { isValidObjectId, resourceNotFound } from '../utils/helper.ts';
import { appError } from '../exception/appError.ts';

import CategoryRepository from '../repositories/category.repository.ts';

const categorySchema = z.object({
  category_id: z.string().trim(),
  category_name: z.string().trim(),
  category_imgUrl: z.string().trim(),
});

class CategoryService {
  async getAll(): Promise<ICategory[]> {
    return await CategoryRepository.findAll();
  }

  async getById(id: string): Promise<ICategory | null> {
    isValidObjectId(id);

    return await CategoryRepository.findById(id);
  }

  async add(category: ICategory): Promise<ICategory | null> {
    const result = categorySchema.safeParse(category);

    if (!result.success) {
      throw new appError(400, result.error.issues[0].message);
    }

    return await CategoryRepository.insert(category);
  }

  async update(id: string, newCategory: ICategory): Promise<ICategory | null> {
    isValidObjectId(id);

    const category = await this.getById(id);

    resourceNotFound(category);

    const result = categorySchema.safeParse(newCategory);

    if (!result.success) {
      throw new appError(400, result.error.issues[0].message);
    }

    const newDataCategory: ICategory = {
      ...category,
      ...newCategory,
    };

    return await CategoryRepository.update(id, newDataCategory);
  }

  async remove(id: string) {
    isValidObjectId(id);

    const category = await this.getById(id);

    resourceNotFound(category);

    return await CategoryRepository.delete(id);
  }
}

export default new CategoryService();
