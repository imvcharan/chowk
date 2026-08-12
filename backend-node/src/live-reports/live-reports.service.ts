import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class LiveReportsService {
  constructor(private readonly prisma: PrismaService) {}
  list() { return this.prisma.liveReport.findMany({ orderBy: [{ sequenceId: 'desc' }, { createdAt: 'desc' }], take: 50, include: { createdBy: true } }).then((data) => ({ success: true, data })); }
  async create(userId: number, input: { title?: string; body?: string; image_url?: string; video_url?: string }) { const latest = await this.prisma.liveReport.findFirst({ orderBy: { sequenceId: 'desc' } }); const sequenceId = (latest?.sequenceId ?? BigInt(0)) + BigInt(1); const data = await this.prisma.liveReport.create({ data: { sequenceId, title: input.title?.trim(), body: input.body?.trim(), imageUrl: input.image_url, videoUrl: input.video_url, createdById: userId } }); return { success: true, data }; }
  async update(id: number, input: { title?: string; body?: string; image_url?: string; video_url?: string }) { const existing = await this.prisma.liveReport.findUnique({ where: { id: BigInt(id) } }); if (!existing) throw new NotFoundException('Live report not found'); if (!input.title?.trim() && !input.body?.trim()) throw new NotFoundException('title or body required'); const data = await this.prisma.liveReport.update({ where: { id: BigInt(id) }, data: { title: input.title?.trim(), body: input.body?.trim(), imageUrl: input.image_url?.trim(), videoUrl: input.video_url?.trim() } }); return { success: true, data }; }
  async remove(id: number) { const result = await this.prisma.liveReport.deleteMany({ where: { id: BigInt(id) } }); if (!result.count) throw new NotFoundException('Live report not found'); return { success: true, message: 'Live report deleted' }; }
}