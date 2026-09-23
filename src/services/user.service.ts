import { IUser } from '../interfaces/user.interface.ts';
import { hashPassword } from '../utils/helper.ts';
import { appError } from '../exception/appError.ts';
import UserRepository from '../repositories/user.repository.ts';

class UserService {
  async register(user: IUser): Promise<IUser | null> {
    if (
      typeof user.email !== 'string' ||
      !user.email.trim() ||
      typeof user.telephone !== 'string' ||
      !user.telephone.trim() ||
      typeof user.username !== 'string' ||
      user.username.trim() ||
      typeof user.password !== 'string' ||
      !user.password.trim()
    ) {
      throw new appError(
        400,
        'Email, telephone, username, and password are required.',
      );
    }
    const hashedPassword = await hashPassword(user.password);

    // add more logic

    const hashedPasswordUser = {
      ...user,
      password: hashedPassword,
    };

    return await UserRepository.register(hashedPasswordUser);
  }
}

export default new UserService();
