import {
  IsNumber,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateProductDto {
  @IsString()
  @MinLength(6)
  @MaxLength(8)
  product_id: string;

  @IsString()
  @MinLength(2)
  @MaxLength(150)
  product_name: string;
}
