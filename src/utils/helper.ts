import mongoose from 'mongoose';
import bcrypt from 'bcrypt';

import { appError } from '../exception/appError.ts';

import { IUser } from '../interfaces/user.interface.ts';

export const isValidObjectId = (id: string): void => {
  if (!mongoose.Types.ObjectId.isValid(id)) {
    throw new appError(400, 'Invalid id format.');
  }
};

export const resourceNotFound = (
  resource: unknown,
  name: string = 'data',
): void => {
  if (!resource) {
    throw new appError(404, `${name} not found.`);
  }
};

export const hashPassword = async (password: string): Promise<string> => {
  return await bcrypt.hash(password, 10);
};

export const dateFormatter = (date: number): string => {
  const options: Intl.DateTimeFormatOptions = {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  };

  return new Intl.DateTimeFormat('en-US', options).format(date);
};

export const comparePassword = async (
  password: string,
  hashedPassword: string,
): Promise<boolean> => {
  const isValid: boolean = await bcrypt.compare(password, hashedPassword);

  return isValid;
};
