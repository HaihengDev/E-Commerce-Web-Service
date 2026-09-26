import { z } from 'zod';

import { ICustomer } from '../interfaces/customer.interface.ts';
import { IEmployee } from '../interfaces/employee.interface.ts';
import { ILogin, IUser } from '../interfaces/user.interface.ts';

import { IAuthResponse } from '../interfaces/user.interface.ts';
import {
  comparePassword,
  dateFormatter,
  hashPassword,
  resourceNotFound,
} from '../utils/helper.ts';
import { appError } from '../exception/appError.ts';
import { generateToken } from '../auth/jwt.ts';

import CustomerRepository from '../repositories/customer.repository.ts';
import EmployeeRepository from '../repositories/employee.repository.ts';
import UserRepository from '../repositories/user.repository.ts';

const registerSchema = z.object({
  email: z.string().trim().email('Invalid email format.'),
  telephone: z.string().trim().min(1, 'Telephone is required.'),
  username: z.string().trim().min(1, 'Username is required.'),
  password: z.string().trim().min(6, 'Password must be atleast 6 characters.'),
});

class UserService {
  async register(user: IUser): Promise<IAuthResponse> {
    const result = registerSchema.safeParse(user);

    if (!result.success) {
      throw new appError(400, result.error.issues[0].message);
    }

    const existing = await this.getUserByEmail(user.email);

    if (existing) {
      throw new appError(409, 'email is already taken.');
    }

    const hashedPassword = await hashPassword(user.password);

    const userData: IUser = {
      ...user,
      password: hashedPassword,
    };

    const createdUser = await UserRepository.register(userData);

    if (!createdUser) {
      throw new appError(500, 'Failed to create user.');
    }

    const token = generateToken(createdUser._id!.toString());
    const { password: _password, ...safeUser } = createdUser;

    if (user.role === 'USER') {
      const customer: ICustomer = {
        customer_name: user.username,
      };

      await CustomerRepository.insert(customer);
    }

    if (user.role === 'EMPLOYEE' || user.role === 'ADMIN') {
      const employee: IEmployee = {
        employee_name: user.username,
        employment_date: dateFormatter(Date.now()),
      };

      await EmployeeRepository.insert(employee);
    }

    return {
      user: safeUser as IUser,
      token,
    };
  }

  async getUserByEmail(email: string): Promise<IUser | null> {
    const result = registerSchema.safeParse({ email: email });

    if (!result.success) {
      throw new appError(400, result.error.issues[0].message);
    }

    const user = await UserRepository.findUserByEmail(email);

    resourceNotFound(user, 'User');

    return user;
  }

  async getUserByUsername(username: string): Promise<IUser | null> {
    const result = registerSchema.safeParse({ username: username });

    if (!result.success) {
      throw new appError(400, result.error.issues[0].message);
    }

    const user = await UserRepository.findUserByUsername(username);

    resourceNotFound(user, 'User');

    return user;
  }

  async login(user: ILogin): Promise<IAuthResponse> {
    const result = registerSchema.safeParse(user);

    if (!result.success) {
      throw new appError(400, result.error.issues[0].message);
    }

    const userData = await this.getUserByEmail(user.email);

    resourceNotFound(userData, 'User');

    const isValidPassword = await comparePassword(
      user.password,
      userData!.password,
    );

    if (!isValidPassword) {
      throw new appError(409, 'Passwod is invalid.');
    }

    const token = generateToken(userData!._id!.toString());

    return {
      user: userData as IUser,
      token,
    };
  }
}

export default new UserService();
