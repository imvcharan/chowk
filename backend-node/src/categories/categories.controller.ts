import { Body, Controller, Get, Post, Req, UseGuards, ForbiddenException } from '@nestjs/common';
import { IsString, MinLength } from 'class-validator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CategoriesService } from './categories.service';

class CreateCategoryDto {
  @IsString()
  @MinLength(2)
  name!: string;
}

@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Get()
  async list() {
    return { success: true, data: await this.categoriesService.list() };
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  async create(@Body() dto: CreateCategoryDto, @Req() request: { user: { role: string } }) {
    if (!['admin', 'super_admin', 'editor'].includes(request.user.role)) throw new ForbiddenException('Category management is not allowed for this role');
    const category = await this.categoriesService.create(dto.name);
    return { success: true, data: category };
  }
}