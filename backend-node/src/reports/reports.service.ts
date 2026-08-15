import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class ReportsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(userId: number, articleId: number, reason: string, details?: string) {
    if (!(await this.prisma.article.findUnique({ where: { id: articleId }, select: { id: true } }))) throw new NotFoundException('News article not found');
    await this.prisma.report.create({ data: { userId, articleId, reason: reason.trim(), details: details?.trim() } });
    return { success: true };
  }

  async list() {
    const reports = await this.prisma.report.findMany({ include: { user: true, article: true }, orderBy: { createdAt: 'desc' } });
    return { success: true, data: reports.map((r: any) => ({ id: r.id, news_id: r.articleId, user_id: r.userId, reported_by: r.user.name, reason: r.reason, details: r.details, created_at: r.createdAt, news_title: r.article.title })) };
  }
}