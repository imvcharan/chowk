import { Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Query, Req, UseGuards } from '@nestjs/common';
import { IsInt, IsString, MinLength } from 'class-validator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { SocialService } from './social.service';

class CreateCommentDto { @IsString() @MinLength(3) content!: string; }
class ArticleDto { @IsInt() news_id!: number; }

@Controller()
export class SocialController {
  constructor(private readonly social: SocialService) {}

  @Get('bookmarks') @UseGuards(JwtAuthGuard)
  bookmarks(@Req() req: any, @Query('page') page = '1', @Query('limit') limit = '20') { return this.social.bookmarks(req.user.id, Math.max(1, Number(page)), Math.min(50, Number(limit))); }
  @Post('bookmarks') @UseGuards(JwtAuthGuard)
  addBookmark(@Req() req: any, @Body() dto: ArticleDto) { return this.social.addBookmark(req.user.id, dto.news_id); }
  @Delete('bookmarks/:id') @UseGuards(JwtAuthGuard)
  removeBookmark(@Req() req: any, @Param('id', ParseIntPipe) id: number) { return this.social.removeBookmark(req.user.id, id); }

  @Get('likes/:id') @UseGuards(JwtAuthGuard)
  likeStatus(@Req() req: any, @Param('id', ParseIntPipe) id: number) { return this.social.likeStatus(req.user.id, id); }
  @Post('likes/:id') @UseGuards(JwtAuthGuard)
  like(@Req() req: any, @Param('id', ParseIntPipe) id: number) { return this.social.like(req.user.id, id); }
  @Delete('likes/:id') @UseGuards(JwtAuthGuard)
  unlike(@Req() req: any, @Param('id', ParseIntPipe) id: number) { return this.social.unlike(req.user.id, id); }

  @Get('comments/:id')
  comments(@Param('id', ParseIntPipe) id: number, @Query('page') page = '1', @Query('limit') limit = '10') { return this.social.comments(id, Math.max(1, Number(page)), Math.min(50, Number(limit))); }
  @Post('comments/:id') @UseGuards(JwtAuthGuard)
  addComment(@Req() req: any, @Param('id', ParseIntPipe) id: number, @Body() dto: CreateCommentDto) { return this.social.addComment(req.user.id, id, dto.content); }
  @Delete('comments/:id') @UseGuards(JwtAuthGuard)
  removeComment(@Req() req: any, @Param('id', ParseIntPipe) id: number) { return this.social.removeComment(req.user.id, id); }
}