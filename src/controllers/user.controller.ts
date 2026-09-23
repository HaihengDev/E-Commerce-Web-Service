import { Request, Response } from 'express';
import { IUser } from '../interfaces/user.interface.ts';
import UserService from '../services/user.service.ts';
import { sendError } from '../exception/sendError.ts';

export const register = async (
  req: Request,
  res: Response,
): Promise<Response> => {
  try {
    const { email, telephone, username, password, role } = req.body;

    const user: IUser = {
      email,
      telephone,
      username,
      password,
    };

    return res.status(200).json({
      message: 'User is registered successfully.',
      data: await UserService.register(user),
    });
  } catch (err) {
    return sendError(res, err);
  }
};
