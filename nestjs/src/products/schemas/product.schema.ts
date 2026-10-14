import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type ProductDocument = HydratedDocument<Product>;

@Schema({
  timestamps: true,
  versionKey: false,
})
export class Product {
  @Prop({ required: true, trim: true, maxLength: 8 })
  product_id: string;

  @Prop({ required: true, trim: true })
  product_name: string;

  @Prop({ required: true, trim: true })
  imgUrl: string;

  @Prop({ required: true, min: 0 })
  stock: number;

  @Prop({ required: true, min: 0, max: 100 })
  discount: number;

  @Prop({ Required: true, min: 0 })
  price: number;
}

export const ProductSchema = SchemaFactory.createForClass(Product);
