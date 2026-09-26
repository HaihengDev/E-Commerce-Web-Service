import { Request, Response } from 'express';
import { IOrder } from '../interfaces/order.interface.ts';
import { appError } from '../exception/appError.ts';
import { sendError } from '../exception/sendError.ts';
import OrderService from '../services/order.service.ts';
import { AuthenticationRequest } from '../middleware/requireAuth.ts';

export const readAllOrders = async (res: Response): Promise<Response> => {
  try {
    const orders = await OrderService.getAll();

    return res.status(200).json({
      data: orders,
    });
  } catch (err) {
    return sendError(res, err);
  }
};

export const readOrderById = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    const id = req.params.id as string;

    const order = await OrderService.getById(id);

    return res.status(200).json({
      data: order,
    });
  } catch (err) {
    return sendError(res, err);
  }
};

export const createOrder = async (
  req: AuthenticationRequest,
  res: Response,
) => {
  try {
    // const user_id = req?.userId;
    // const order: IOrder = {
    //   user_id: String(user_id),
    //   orders: req.body,
    // };
    // return res.status(201).json({
    //   message: 'order is created successfully.',
    //   data: await OrderService.add(order),
    // });
    // --> need more logic for input with customer_id and employee_id
  } catch (err) {
    return sendError(res, err);
  }
};

export const updateOrder = async (req: Request, res: Response) => {
  try {
    // const id = req.params.id as string;
    // const order = await OrderService.getById(id);
    // const newOrder: IOrder = {
    //   ...order,
    //   user_id: order?.user_id as string,
    //   orders: req.body,
    // };
    // return res.status(200).json({
    //   message: 'Order updated successfully',
    //   data: await OrderService.update(id, newOrder),
    // });
    // -> make change after finish cutomer endpoint and employee endpoint
  } catch (err) {
    return sendError(res, err);
  }
};

export const deleteOrder = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    const id = req.params.id as string;

    return res.status(204).json({
      message: 'Order deleted successfully',
      data: await OrderService.remove(id),
    });
  } catch (err) {
    return sendError(res, err);
  }
};
