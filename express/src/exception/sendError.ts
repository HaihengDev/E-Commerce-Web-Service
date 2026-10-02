import { Response } from 'express';
import { appError } from './appError.ts';

export const sendError = (res: Response, err: unknown): Response => {
  if (err instanceof appError) {
    return res.status(err.statusCode).json({ message: err.message });
  }

  return res.status(500).json({
    message: 'Server Error.',
  });
};
