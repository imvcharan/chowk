import { Body, Controller, Delete, ForbiddenException, Get, HttpCode, HttpStatus, Param, ParseIntPipe, Patch, Post, Query, Req, UploadedFile, UseGuards, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { MediaService } from '../media/media.service';
import { AdminService } from './admin.service';

@Controller('admin')
@UseGuards(JwtAuthGuard)
export class AdminController {
  constructor(private readonly admin: AdminService, private readonly media: MediaService) {}

  @Get()
  actionGet(@Req() req: any, @Query('action') action: string, @Query() query: any) {
    this.requireAdmin(req.user.role);
    if (action === 'list_users') return this.admin.users();
    if (action === 'list_categories') return this.admin.categories();
    if (action === 'list_articles') return this.admin.articles(Number(query.page), Number(query.limit));
    if (action === 'get_article') return this.admin.article(Number(query.id));
    if (action === 'list_media') return this.admin.media(Number(query.page), Number(query.limit));
    throw new ForbiddenException('Unknown admin action');
  }

  @Post()
  @UseInterceptors(FileInterceptor('file'))
  actionPost(@Req() req: any, @Query('action') action: string, @Body() body: any, @UploadedFile() file?: Express.Multer.File) {
    this.requireAdmin(req.user.role);
    if (action === 'upload_media') return this.media.save(file!);
    if (action === 'create_category') return this.admin.createCategory(body);
    if (action === 'update_category') return this.admin.updateCategory(Number(body.id), body);
    if (action === 'delete_category') return this.admin.deleteCategory(Number(body.id));
    if (action === 'create_article') return this.admin.createArticle(body, req.user.id);
    if (action === 'update_article') return this.admin.updateArticle(Number(body.id), body);
    if (action === 'publish_article') return this.admin.publishArticle(Number(body.id));
    if (action === 'delete_article') return this.admin.deleteArticle(Number(body.id));
    if (action === 'delete_media') return this.admin.deleteMedia(Number(body.id));
    if (action === 'update_user_role') return this.admin.updateRole(Number(body.user_id), body.role);
    throw new ForbiddenException('Unknown admin action');
  }

  @Get('dashboard') dashboard(@Req() req: any) { this.requireAdmin(req.user.role); return this.admin.dashboard(); }
  @Get('users') users(@Req() req: any) { this.requireAdmin(req.user.role); return this.admin.users(); }
  @Post('users') @HttpCode(HttpStatus.CREATED) createUser(@Req() req: any, @Body() body: any) { this.requireAdmin(req.user.role); return this.admin.createUser(body); }
  @Patch('users/:id/role') updateRole(@Req() req: any, @Param('id', ParseIntPipe) id: number, @Body('role') role: string) { this.requireAdmin(req.user.role); return this.admin.updateRole(id, role); }
  @Delete('users/:id') deleteUser(@Req() req: any, @Param('id', ParseIntPipe) id: number) { this.requireAdmin(req.user.role); return this.admin.deleteUser(id, req.user.id); }

  @Get('categories') categories(@Req() req: any) { this.requireAdmin(req.user.role); return this.admin.categories(); }
  @Post('categories') createCategory(@Req() req: any, @Body() body: any) { this.requireAdmin(req.user.role); return this.admin.createCategory(body); }
  @Patch('categories/:id') updateCategory(@Req() req: any, @Param('id', ParseIntPipe) id: number, @Body() body: any) { this.requireAdmin(req.user.role); return this.admin.updateCategory(id, body); }
  @Delete('categories/:id') deleteCategory(@Req() req: any, @Param('id', ParseIntPipe) id: number) { this.requireAdmin(req.user.role); return this.admin.deleteCategory(id); }

  @Get('articles') articles(@Req() req: any, @Query('page') page = '1', @Query('limit') limit = '50') { this.requireAdmin(req.user.role); return this.admin.articles(Number(page), Number(limit)); }
  @Get('articles/:id') article(@Req() req: any, @Param('id', ParseIntPipe) id: number) { this.requireAdmin(req.user.role); return this.admin.article(id); }
  @Post('articles') createArticle(@Req() req: any, @Body() body: any) { this.requireAdmin(req.user.role); return this.admin.createArticle(body, req.user.id); }
  @Patch('articles/:id') updateArticle(@Req() req: any, @Param('id', ParseIntPipe) id: number, @Body() body: any) { this.requireAdmin(req.user.role); return this.admin.updateArticle(id, body); }
  @Post('articles/:id/publish') publishArticle(@Req() req: any, @Param('id', ParseIntPipe) id: number) { this.requireAdmin(req.user.role); return this.admin.publishArticle(id); }
  @Delete('articles/:id') deleteArticle(@Req() req: any, @Param('id', ParseIntPipe) id: number) { this.requireAdmin(req.user.role); return this.admin.deleteArticle(id); }

  @Get('media') mediaList(@Req() req: any, @Query('page') page = '1', @Query('limit') limit = '50') { this.requireAdmin(req.user.role); return this.admin.media(Number(page), Number(limit)); }
  @Post('media') @UseInterceptors(FileInterceptor('file')) uploadMedia(@Req() req: any, @UploadedFile() file: Express.Multer.File) { this.requireAdmin(req.user.role); return this.media.save(file); }
  @Delete('media/:id') deleteMedia(@Req() req: any, @Param('id', ParseIntPipe) id: number) { this.requireAdmin(req.user.role); return this.admin.deleteMedia(id); }

  private requireAdmin(role: string) {
    if (!['admin', 'super_admin'].includes(role)) throw new ForbiddenException('Admin access required');
  }
}