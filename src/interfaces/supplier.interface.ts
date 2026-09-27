import mongoose from 'mongoose';

export interface ISupplier {
  _id?: mongoose.Types.ObjectId;
  supplier_id: string;
  supplier_name: string;
  address: string;
  phone: string;
}
