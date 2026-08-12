import { Body, Controller, ForbiddenException, Get, Post, Req, UseGuards } from '@nestjs/common';
import { IsInt, IsOptional, IsString, MinLength } from 'class-validator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ReportsService } from './reports.service';

class CreateReportDto { @IsInt() news_id!: number; @IsString() @MinLength(2) reason!: string; @IsOptional() @IsString() details?: string; }

@Controller('reports')
@UseGuards(JwtAuthGuard)
export class ReportsController {
  constructor(private readonly reports: ReportsService) {}
  @Post() create(@Req() req: any, @Body() dto: CreateReportDto) { return this.reports.create(req.user.id, dto.news_id, dto.reason, dto.details); }
  @Get() list(@Req() req: any) { if (!['admin', 'super_admin'].includes(req.user.role)) throw new ForbiddenException('Admin access required'); return this.reports.list(); }
}