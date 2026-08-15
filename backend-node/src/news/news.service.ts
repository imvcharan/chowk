import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import { CreateNewsDto } from './dto/create-news.dto';

@Injectable()
export class NewsService {
  constructor(private readonly prisma: PrismaService) {}

  async list(page: number, limit: number, category?: string, search?: string, featured?: boolean) {
    const where = {
      status: 'published',
      ...(category ? { category: { slug: category } } : {}),
      ...(featured ? { isFeatured: true } : {}),
      ...(search ? { OR: [{ title: { contains: search, mode: 'insensitive' as const } }, { excerpt: { contains: search, mode: 'insensitive' as const } }, { content: { contains: search, mode: 'insensitive' as const } }] } : {}),
    };
    const [articles, total] = await Promise.all([
      this.prisma.article.findMany({ where, include: { category: true, author: true, image: true }, orderBy: { createdAt: 'desc' }, skip: (page - 1) * limit, take: limit }),
      this.prisma.article.count({ where }),
    ]);
    return { success: true, data: articles.map((article: any) => this.present(article)), pagination: { page, limit, total, pages: Math.max(1, Math.ceil(total / limit)) } };
  }

  async search(query: string) {
    const articles = await this.prisma.article.findMany({
      where: { status: 'published', OR: [{ title: { contains: query, mode: 'insensitive' } }, { excerpt: { contains: query, mode: 'insensitive' } }, { content: { contains: query, mode: 'insensitive' } }] },
      include: { category: true, author: true, image: true },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
    return { success: true, data: articles.map((article: any) => this.present(article)) };
  }

  async trending(limit: number) {
    const since = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const articles = await this.prisma.article.findMany({
      where: { status: 'published', createdAt: { gte: since } },
      include: { category: true, author: true, image: true },
      orderBy: [{ viewsCount: 'desc' }, { createdAt: 'desc' }],
      take: limit,
    });
    return { success: true, data: articles.map((article: any) => this.present(article)) };
  }

  async detail(id: number) {
    const article = await this.prisma.article.findUnique({ where: { id }, include: { category: true, author: true, image: true } });
    if (!article) throw new NotFoundException('News article not found');
    await this.prisma.article.update({ where: { id }, data: { viewsCount: { increment: 1 } } });
    return { success: true, data: this.present(article) };
  }

  async create(dto: CreateNewsDto, authorId: number) {
    const slug = `${dto.title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')}-${Date.now()}`;
    const article = await this.prisma.article.create({ data: { title: dto.title.trim(), slug, excerpt: dto.description.trim(), content: dto.content.trim(), categoryId: dto.category_id, authorId, status: dto.is_published === false ? 'draft' : 'published', isFeatured: dto.featured === true, publishedAt: dto.is_published === false ? null : new Date() } });
    return { success: true, news_id: article.id, data: article };
  }

  async update(id: number, input: Partial<CreateNewsDto>) {
    const existing = await this.prisma.article.findUnique({ where: { id } });
    if (!existing) throw new NotFoundException('News article not found');
    const article = await this.prisma.article.update({ where: { id }, data: { title: input.title?.trim(), excerpt: input.description?.trim(), content: input.content?.trim(), categoryId: input.category_id, isFeatured: input.featured, status: input.is_published === undefined ? undefined : (input.is_published ? 'published' : 'draft'), publishedAt: input.is_published ? new Date() : undefined } });
    return { success: true, data: article };
  }

  async remove(id: number) {
    await this.prisma.article.delete({ where: { id } });
    return { success: true };
  }

  private present(article: any) {
    return { id: article.id, title: article.title, slug: article.slug, description: article.excerpt, content: article.content, category_id: article.categoryId, category_name: article.category?.name, author_name: article.author?.name, status: article.status, is_featured: article.isFeatured, views_count: article.viewsCount, published_at: article.publishedAt, created_at: article.createdAt, image_url: article.image?.url ?? null };
  }
}