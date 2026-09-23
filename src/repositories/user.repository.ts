import { IUser } from '../interfaces/user.interface.ts';
import User from '../models/user.model.ts';

class UserRepository {
  async register(user: IUser): Promise<IUser | null> {
    return await User.create(user);
  }
}

export default new UserRepository();
