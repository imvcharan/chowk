import { IsBoolean, IsInt, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class CreateNewsDto {
  @IsString() @MinLength(3) @MaxLength(255) title!: string;
  @IsString() @MinLength(3) description!: string;
  @IsString() @MinLength(3) content!: string;
  @IsInt() category_id!: number;
  @IsOptional() @IsString() image_url?: string;
  @IsOptional() @IsBoolean() featured?: boolean;
  @IsOptional() @IsBoolean() is_published?: boolean;
}