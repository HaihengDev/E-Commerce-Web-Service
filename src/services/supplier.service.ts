import { z } from 'zod';

import { ISupplier } from '../interfaces/supplier.interface.ts';
import { isValidObjectId, resourceNotFound } from '../utils/helper.ts';
import { appError } from '../exception/appError.ts';

import SupplierRepository from '../repositories/supplier.repository.ts';

const supplierSchema = z.object({
  supplier_id: z
    .string({
      message: 'Supplier Id is must be string',
    })
    .trim()
    .min(1, 'Supplier Id is required'),
  supplier_name: z
    .string({
      message: 'Supplier Name is must be string',
    })
    .trim()
    .min(1, 'Supplier Name is required'),
  address: z
    .string({
      message: 'Address is must be string',
    })
    .trim()
    .min(1, 'Supplier Id is required'),
  phone: z
    .string({ message: 'Phone Number is must be string' })
    .trim()
    .min(1, 'Phone number is atleast 8 length'),
});

class SupplierService {
  async getAll(): Promise<ISupplier[]> {
    return await SupplierRepository.findAll();
  }

  async getById(id: string): Promise<ISupplier | null> {
    isValidObjectId(id);

    const supplier = await SupplierRepository.findById(id);

    resourceNotFound(supplier);

    return supplier;
  }

  async add(supplier: ISupplier): Promise<ISupplier | null> {
    const result = supplierSchema.safeParse(supplier);

    if (!result.success) {
      throw new appError(400, result.error.issues[0].message);
    }

    return await SupplierRepository.insert(supplier);
  }

  async update(id: string, newSupplier: ISupplier): Promise<ISupplier | null> {
    isValidObjectId(id);

    const supplier = await this.getById(id);

    resourceNotFound(supplier);

    const supplierData: ISupplier = {
      ...supplier,
      ...newSupplier,
    };

    return await SupplierRepository.update(id, supplierData);
  }

  async remove(id: string): Promise<ISupplier | null> {
    isValidObjectId(id);

    const existingSupplier = await this.getById(id);

    resourceNotFound(existingSupplier);

    return await SupplierRepository.delete(id);
  }
}

export default new SupplierService();
