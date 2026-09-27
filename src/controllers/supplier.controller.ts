import { Request, Response } from 'express';

import { sendError } from '../exception/sendError.ts';
import { ISupplier } from '../interfaces/supplier.interface.ts';

import SupplierService from '../services/supplier.service.ts';

export const readAllSuppliers = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    return res.status(200).json({ data: await SupplierService.getAll() });
  } catch (err) {
    return sendError(res, err);
  }
};

export const readSupplierById = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    const id = req.params.id as string;

    const supplier = await SupplierService.getById(id);

    return res.status(200).json({
      data: supplier,
    });
  } catch (err) {
    return sendError(res, err);
  }
};

export const createSupplier = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    const { supplier_id, supplier_name, address, phone } = req.body;

    const supplier: ISupplier = {
      supplier_id,
      supplier_name,
      address,
      phone,
    };

    return res.status(201).json({
      message: 'Supplier is created successfully.',
      data: await SupplierService.add(supplier),
    });
  } catch (err) {
    return sendError(res, err);
  }
};

export const updateSupplier = async (req: Request, res: Response) => {
  try {
    const id = req.params.id as string;

    const { supplier_id, supplier_name, address, phone } = req.body;

    const newSupplier: ISupplier = {
      supplier_id,
      supplier_name,
      address,
      phone,
    };

    return res.status(200).json({
      message: 'Supplier updated successfully.',
      data: await SupplierService.update(id, newSupplier),
    });
  } catch (err) {
    return sendError(res, err);
  }
};

export const deleteSupplier = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    const id = req.params.id as string;

    return res.status(204).json({
      message: 'Supplier deleted successfully.',
      data: await SupplierService.remove(id),
    });
  } catch (err) {
    return sendError(res, err);
  }
};
