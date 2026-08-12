import { Body, Controller, Delete, Get, ParseIntPipe, Post, Put, Query, Req, UseGuards, ForbiddenException } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { LiveReportsService } from './live-reports.service';

@Controller('live')
export class LiveReportsController {
  constructor(private readonly live: LiveReportsService) {}
  @Get() list() { return this.live.list(); }
  @Post() @UseGuards(JwtAuthGuard) create(@Req() req: any, @Body() body: any) { this.requirePublisher(req.user.role); return this.live.create(req.user.id, body); }
  @Put() @UseGuards(JwtAuthGuard) update(@Req() req: any, @Query('id', ParseIntPipe) id: number, @Body() body: any) { this.requirePublisher(req.user.role); return this.live.update(id, body); }
  @Delete() @UseGuards(JwtAuthGuard) remove(@Req() req: any, @Query('id', ParseIntPipe) id: number) { this.requirePublisher(req.user.role); return this.live.remove(id); }

  private requirePublisher(role: string) {
    if (!['admin', 'super_admin', 'reporter'].includes(role)) throw new ForbiddenException('Live reporting is not allowed for this role');
  }
}