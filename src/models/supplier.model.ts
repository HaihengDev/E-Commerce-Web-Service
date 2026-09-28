import mongoose from 'mongoose';
import { ISupplier } from '../interfaces/supplier.interface.ts';
import { counterId } from '../utils/helper.ts';

const supplierSchema = new mongoose.Schema<ISupplier>({
  _id: {
    type: mongoose.Types.ObjectId,
  },
  supplier_id: {
    type: String,
    required: true,
    unique: true,
  },
  supplier_name: {
    type: String,
    required: true,
  },
  address: {
    type: String,
    required: true,
  },
  phone: {
    type: String,
    required: true,
  },
});

supplierSchema.pre('save', async function () {
  this.supplier_id = await counterId('Supplier', 'sup');
});

export default mongoose.model<ISupplier>('Supplier', supplierSchema);
