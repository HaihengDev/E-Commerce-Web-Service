import { z } from 'zod';
import { IUser } from '../interfaces/user.interface.ts';
import { IRegisterResponse } from '../interfaces/user.interface.ts';
import { hashPassword, resourceNotFound } from '../utils/helper.ts';
import { appError } from '../exception/appError.ts';
import { generateToken } from '../auth/jwt.ts';
import UserRepository from '../repositories/user.repository.ts';
import CustomerRepository from '../repositories/customer.repository.ts';
import { ICustomer } from '../interfaces/customer.interface.ts';

const registerSchema = z.object({
  email: z.string().trim().email('Invalid email format.'),
  telephone: z.string().trim().min(1, 'Telephone is required.'),
  username: z.string().trim().min(1, 'Username is required.'),
  password: z.string().trim().min(6, 'Password must be atleast 6 characters.'),
});

class UserService {
  async register(user: IUser): Promise<IRegisterResponse> {
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

    // --> add for employee

    return {
      user: safeUser as IUser,
      token,
    };
  }

  async getUserByEmail(email: string): Promise<IUser | null> {
    const result = registerSchema.safeParse({ email: email });

    if (!result.success) {
      throw new appError(404, result.error.issues[0].message);
    }

    const user = await UserRepository.findUserByEmail(email);

    resourceNotFound(user, 'User');

    return user;
  }
}

export default new UserService();
