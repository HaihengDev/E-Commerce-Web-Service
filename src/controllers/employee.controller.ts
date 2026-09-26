import { Request, Response } from 'express';

import { sendError } from '../exception/sendError.ts';

import EmployeeService from '../services/employee.service.ts';

export const readAllEmployees = async (res: Response): Promise<Response> => {
  try {
    const employees = await EmployeeService.getAll();

    return res.status(200).json({ data: employees });
  } catch (err) {
    return sendError(res, err);
  }
};

export const readEmployeeById = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    const id = req.params.id as string;
    const employee = await EmployeeService.getById(id);

    return res.status(200).json({ data: employee });
  } catch (err) {
    return sendError(res, err);
  }
};
