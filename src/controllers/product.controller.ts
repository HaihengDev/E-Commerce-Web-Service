import { Request, Response } from 'express';
import { IProduct } from '../interfaces/product.interface.ts';
import { sendError } from '../exception/sendError.ts';
import ProductService from '../services/product.service.ts';

export const readAllProducts = async (res: Response): Promise<Response> => {
  try {
    return res.status(200).json({ data: await ProductService.getAll() });
  } catch (err) {
    return sendError(res, err);
  }
};

export const readProductById = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    const id = req.params.id as string;

    return res.status(200).json({ data: await ProductService.getById(id) });
  } catch (err) {
    return sendError(res, err);
  }
};

export const createProduct = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    const { product_name, stock, discount, price, category } = req.body;

    const product: IProduct = {
      product_name,
      stock,
      discount,
      price,
      category,
    };

    return res.status(201).json({
      message: 'Product created successfully.',
      data: await ProductService.add(product),
    });
  } catch (err) {
    return sendError(res, err);
  }
};

export const updateProduct = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    const id = req.params.id as string;
    const { product_name, product_imgUrl, stock, discount, price, category } =
      req.body;

    const newProduct: IProduct = {
      product_name,
      product_imgUrl,
      stock,
      discount,
      price,
      category,
    };

    return res.status(200).json({
      message: 'Product updated successfully.',
      data: await ProductService.update(id, newProduct),
    });
  } catch (err) {
    return sendError(res, err);
  }
};

export const deleteProduct = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    const id = req.params.id as string;

    return res.status(204).json({
      message: 'Product deleted successfully.',
      data: await ProductService.remove(id),
    });
  } catch (err) {
    return sendError(res, err);
  }
};
