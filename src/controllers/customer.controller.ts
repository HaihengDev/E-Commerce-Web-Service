import { Request, Response } from 'express';
import { sendError } from '../exception/sendError.ts';

import CustomerService from '../services/customer.service.ts';

export const readAllCustomers = async (res: Response): Promise<Response> => {
  try {
    const customers = await CustomerService.getAll();

    return res.status(200).json({ data: customers });
  } catch (err) {
    return sendError(res, err);
  }
};

export const readCustomerById = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    const id = req.params.id as string;

    const customer = await CustomerService.getById(id);

    return res.status(200).json({ data: customer });
  } catch (err) {
    return sendError(res, err);
  }
};
