import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class CreateStreamDto {
  @IsString()
  @MinLength(3)
  @MaxLength(255)
  title!: string;

  @IsOptional()
  @IsString()
  @MaxLength(5000)
  description?: string;
}