import { ISupplier } from '../interfaces/supplier.interface.ts';
import Supplier from '../models/supplier.model.ts';

class SupplierRepository {
  async findAll(): Promise<ISupplier[]> {
    return await Supplier.find();
  }

  async findById(id: string): Promise<ISupplier | null> {
    return await Supplier.findById(id);
  }

  async insert(supplier: ISupplier): Promise<ISupplier | null> {
    return await Supplier.create(supplier);
  }

  async update(id: string, newSupplier: ISupplier): Promise<ISupplier | null> {
    return await Supplier.findByIdAndUpdate(id, newSupplier);
  }

  async delete(id: string): Promise<ISupplier | null> {
    return await Supplier.findByIdAndDelete(id);
  }
}

export default new SupplierRepository();
