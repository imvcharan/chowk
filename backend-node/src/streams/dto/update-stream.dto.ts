import { IsIn } from 'class-validator';

export class UpdateStreamDto {
  @IsIn(['LIVE', 'ENDED'])
  status!: 'LIVE' | 'ENDED';
}