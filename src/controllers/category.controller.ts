import { Request, Response } from 'express';
import { sendError } from '../exception/sendError.ts';
import { ICategory } from '../interfaces/category.interface.ts';
import CategoryService from '../services/category.service.ts';

export const readAllCategories = async (res: Response): Promise<Response> => {
  try {
    return res.status(200).json({ data: await CategoryService.getAll() });
  } catch (err) {
    return sendError(res, err);
  }
};

export const readCategoryById = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    const id = req.params.id as string;

    return res.status(200).json({ data: await CategoryService.getById(id) });
  } catch (err) {
    return sendError(res, err);
  }
};

export const createCategory = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    const category: ICategory = {
      category_name: req.body,
    };

    return res.status(201).json({
      message: 'Category created successfully.',
      data: await CategoryService.add(category),
    });
  } catch (err) {
    return sendError(res, err);
  }
};

export const updateCategory = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    const id = req.params.id as string;

    const newCategory: ICategory = {
      category_name: req.body,
      // category_imgUrl: req.file, --> need to be add multer on route and middleware
    };

    return res.status(200).json({
      message: 'Category updated successfully.',
      data: await CategoryService.update(id, newCategory),
    });
  } catch (err) {
    return sendError(res, err);
  }
};

export const deleteCategory = async (req: Request, res: Response) => {
  try {
    const id = req.params.id as string;

    return res.status(204).json({
      message: 'Category deleted successfully.',
      data: await CategoryService.remove(id),
    });
  } catch (err) {
    return sendError(res, err);
  }
};
