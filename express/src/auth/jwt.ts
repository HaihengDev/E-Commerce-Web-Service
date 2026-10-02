import jwt from 'jsonwebtoken';
import { appError } from '../exception/appError.ts';

export const generateToken = (userId: string) => {
  const secret = process.env.JWT_SECRET;

  if (!secret) {
    throw new appError(500, 'JWT_SECRET is not configured.');
  }

  return jwt.sign({ userId }, secret, { expiresIn: '1h' });
};

export const verifyToken = (token: string) => {
  const secret = process.env.JWT_SECRET;

  if (!secret) {
    throw new appError(500, 'JWT_SECRET is not configured.');
  }

  const payload = jwt.verify(token, secret);

  if (typeof payload === 'string' || typeof payload.userId !== 'string') {
    throw new appError(401, 'Invalid authentication token.');
  }

  return payload.userId;
};
