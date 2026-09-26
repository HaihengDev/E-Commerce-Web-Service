import { Request, Response } from 'express';
import { ILogin, IUser } from '../interfaces/user.interface.ts';
import UserService from '../services/user.service.ts';
import { sendError } from '../exception/sendError.ts';
import { comparePassword } from '../utils/helper.ts';

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
      role,
    };

    return res.status(200).json({
      message: 'User is registered successfully.',
      data: await UserService.register(user),
    });
  } catch (err) {
    return sendError(res, err);
  }
};

export const login = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    const user: ILogin = {
      email,
      password,
    };

    return res.status(201).json({
      message: 'Logged in successfully',
      data: await UserService.login(user),
    });
  } catch (err) {
    return sendError(res, err);
  }
};
