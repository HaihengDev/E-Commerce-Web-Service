import { IUser, UserRole } from '../interfaces/user.interface.ts';
import User from '../models/user.model.ts';

class UserRepository {
  async register(user: IUser): Promise<IUser | null> {
    return await User.create(user);
  }

  async findUserByEmail(email: string): Promise<IUser | null> {
    return await User.findOne({ email: email });
  }

  async findAllNormalUser() {
    return await User.find({ role: UserRole.User });
  }

  async findAllAdmin() {
    return await User.find({ role: UserRole.Admin });
  }
}

export default new UserRepository();
