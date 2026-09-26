import { ISupplier } from '../interfaces/supplier.interface.ts';
import SupplierRepository from '../repositories/supplier.repository.ts';

class SupplierService {
  async getAll(): Promise<ISupplier[]> {
    return await SupplierRepository.findAll();
  }

  async getById(id: string): Promise<ISupplier | null> {
    // add validation before continue to find supplier

    return await SupplierRepository.findById(id);
  }

  async add(supplier: ISupplier): Promise<ISupplier | null> {
    // add validation before continue to insert

    return await SupplierRepository.insert(supplier);
  }

  async update(id: string, newSupplier: ISupplier): Promise<ISupplier | null> {
    // add validation before continue to update

    return await SupplierRepository.update(id, newSupplier);
  }

  async remove(id: string): Promise<ISupplier | null> {
    // add validation before continue to delete supplier

    return await SupplierRepository.delete(id);
  }
}

export default new SupplierService();
