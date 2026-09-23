import { NextFunction, Request, Response } from 'express';
import { appError } from '../exception/appError.ts';
import { verifyToken } from '../auth/jwt.ts';

export interface AuthenticationRequest extends Request {
  userId?: string;
}

export const requireAuth = (
  req: AuthenticationRequest,
  res: Response,
  next: NextFunction,
): void => {
  const authorization = req.header('authorization');

  if (!authorization?.startsWith('Bearer ')) {
    res.status(401).json({ message: 'Authentication token is required.' });
    return;
  }

  try {
    req.userId = verifyToken(authorization.slice('Bearer '.length));
    next();
  } catch (err) {
    if (err instanceof appError && err.statusCode === 500) {
      next(err);
      return;
    }

    res
      .status(401)
      .json({ message: 'Invalid or expired authenitcation token.' });
  }
};
