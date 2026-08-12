import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put, Query, Req, UseGuards, ForbiddenException } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateNewsDto } from './dto/create-news.dto';
import { NewsService } from './news.service';

@Controller('news')
export class NewsController {
  constructor(private readonly newsService: NewsService) {}

  @Get()
  list(@Query('page') page = '1', @Query('limit') limit = '20', @Query('category') category?: string, @Query('search') search?: string, @Query('featured') featured?: string) {
    return this.newsService.list(Math.max(1, Number(page)), Math.min(50, Math.max(1, Number(limit))), category, search, featured === 'true');
  }

  @Get(':id')
  detail(@Param('id', ParseIntPipe) id: number) {
    return this.newsService.detail(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  create(@Body() dto: CreateNewsDto, @Req() request: { user: { id: number; role: string } }) {
    if (!['admin', 'super_admin', 'editor'].includes(request.user.role)) throw new ForbiddenException('News publishing is not allowed for this role');
    return this.newsService.create(dto, request.user.id);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: Partial<CreateNewsDto>, @Req() request: { user: { role: string } }) {
    if (!['admin', 'super_admin', 'editor'].includes(request.user.role)) throw new ForbiddenException('News editing is not allowed for this role');
    return this.newsService.update(id, dto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  remove(@Param('id', ParseIntPipe) id: number, @Req() request: { user: { role: string } }) {
    if (!['admin', 'super_admin'].includes(request.user.role)) throw new ForbiddenException('News deletion is not allowed for this role');
    return this.newsService.remove(id);
  }
}