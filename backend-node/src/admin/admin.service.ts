import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';
import * as argon2 from 'argon2';

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  async dashboard() {
    const [users, articles, published, categories, media, recentArticles, recentUsers] = await Promise.all([
      this.prisma.user.count(), this.prisma.article.count(), this.prisma.article.count({ where: { status: 'published' } }),
      this.prisma.category.count(), this.prisma.media.count(),
      this.prisma.article.findMany({ orderBy: { createdAt: 'desc' }, take: 5, select: { id: true, title: true, status: true, createdAt: true } }),
      this.prisma.user.findMany({ orderBy: { createdAt: 'desc' }, take: 5, select: { id: true, name: true, email: true, role: true, createdAt: true } }),
    ]);
    return { success: true, data: { counts: { users, articles, published, categories, media }, recent_articles: recentArticles, recent_users: recentUsers } };
  }

  async users() { return { success: true, data: await this.prisma.user.findMany({ orderBy: { createdAt: 'desc' }, select: { id: true, name: true, email: true, role: true, userCode: true, city: true, state: true, isActive: true, createdAt: true } }) }; }

  async createUser(body: any) {
    const allowedRoles = ['subscriber', 'reporter', 'editor', 'admin', 'super_admin', 'publisher', 'moderator'];
    const name = (body.name ?? body.username ?? '').toString().trim();
    const email = body.email?.toString().trim().toLowerCase();
    const password = body.password?.toString();
    const role = (body.role ?? 'subscriber').toString().trim();
    const city = body.city?.toString().trim() || null;
    const state = body.state?.toString().trim() || null;

    if (!name || !email || !password) {
      throw new BadRequestException('Name, email, and password are required');
    }
    if (password.length < 8) {
      throw new BadRequestException('Password must be at least 8 characters');
    }
    if (!allowedRoles.includes(role)) {
      throw new BadRequestException('Invalid role');
    }
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      throw new BadRequestException('Invalid email address');
    }

    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) {
      throw new BadRequestException('Email is already registered');
    }

    const createdUser = await this.prisma.user.create({
      data: {
        name,
        email,
        passwordHash: await argon2.hash(password),
        role,
        city,
        state,
      },
    });

    const userCode = this.buildUserCode(createdUser.id, createdUser.city, createdUser.state, email);
    const user = await this.prisma.user.update({ where: { id: createdUser.id }, data: { userCode } });

    return {
      success: true,
      data: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        userCode: user.userCode,
        city: user.city,
        state: user.state,
      },
    };
  }

  async updateRole(id: number, role: string) {
    const allowedRoles = ['subscriber', 'reporter', 'editor', 'admin', 'super_admin', 'publisher', 'moderator'];
    if (!allowedRoles.includes(role?.trim())) throw new BadRequestException('Invalid role');
    try { await this.prisma.user.update({ where: { id }, data: { role: role.trim() } }); } catch { throw new NotFoundException('User not found'); }
    return { success: true };
  }

  async deleteUser(id: number, actorId: number) {
    if (id === actorId) throw new BadRequestException('Cannot delete your own account');
    const user = await this.prisma.user.findUnique({ where: { id }, select: { id: true, role: true } });
    if (!user) throw new NotFoundException('User not found');
    if (user.role === 'super_admin') throw new BadRequestException('Cannot delete super admin account');
    await this.prisma.user.delete({ where: { id } });
    return { success: true };
  }

  private buildLocationPrefix(city?: string | null, state?: string | null, email?: string): string {
    const normalize = (value: string, length: number) => {
      return value.replace(/[^A-Za-z]/g, '').toUpperCase().padEnd(length, 'X').slice(0, length);
    };

    if (city?.trim() && state?.trim()) {
      return normalize(city.trim().split(/\s+/)[0], 2) + normalize(state.trim().split(/\s+/)[0], 2);
    }
    if (city?.trim()) {
      return normalize(city.trim(), 4);
    }
    if (state?.trim()) {
      return normalize(state.trim(), 4);
    }
    const domain = email?.split('@')[1]?.split('.')[0] ?? 'USER';
    return normalize(domain, 4);
  }

  private buildUserCode(id: number, city: string | null, state: string | null, email: string) {
    const prefix = this.buildLocationPrefix(city, state, email);
    return `${prefix}${id.toString().padStart(5, '0')}`;
  }

  categories() { return this.prisma.category.findMany({ orderBy: { name: 'asc' } }).then((data: any) => ({ success: true, data })); }
  async createCategory(body: { name?: string; slug?: string }) { if (!body.name?.trim() || !body.slug?.trim()) throw new BadRequestException('Name and slug are required'); const data = await this.prisma.category.create({ data: { name: body.name.trim(), slug: body.slug.trim() } }); return { success: true, data }; }
  async updateCategory(id: number, body: { name?: string; slug?: string }) { if (!body.name?.trim() || !body.slug?.trim()) throw new BadRequestException('Name and slug are required'); try { const data = await this.prisma.category.update({ where: { id }, data: { name: body.name.trim(), slug: body.slug.trim() } }); return { success: true, data }; } catch { throw new NotFoundException('Category not found'); } }
  async deleteCategory(id: number) { try { await this.prisma.category.delete({ where: { id } }); return { success: true }; } catch { throw new NotFoundException('Category not found'); } }

  async articles(page: number, limit: number) { const safePage = Math.max(1, page || 1); const safeLimit = Math.min(200, Math.max(1, limit || 50)); const [data, total] = await Promise.all([this.prisma.article.findMany({ orderBy: { createdAt: 'desc' }, skip: (safePage - 1) * safeLimit, take: safeLimit, select: { id: true, title: true, slug: true, status: true, publishedAt: true, createdAt: true } }), this.prisma.article.count()]); return { success: true, data, total, page: safePage, limit: safeLimit }; }
  async article(id: number) { const data = await this.prisma.article.findUnique({ where: { id }, select: { id: true, title: true, slug: true, excerpt: true, content: true, categoryId: true, status: true, isFeatured: true, imageId: true } }); if (!data) throw new NotFoundException('Article not found'); return { success: true, data }; }
  async createArticle(body: any, authorId: number) { if (!body.title?.trim() || !body.slug?.trim()) throw new BadRequestException('Title and slug are required'); const data = await this.prisma.article.create({ data: { title: body.title.trim(), slug: body.slug.trim(), excerpt: body.excerpt?.trim(), content: body.content ?? '', categoryId: body.category_id ? Number(body.category_id) : null, imageId: body.image_id ? Number(body.image_id) : null, authorId, status: ['draft', 'published', 'archived'].includes(body.status) ? body.status : 'draft', isFeatured: Boolean(body.is_featured), publishedAt: body.status === 'published' ? new Date() : null } }); return { success: true, id: data.id, data }; }
  async updateArticle(id: number, body: any) { if (!body.title?.trim() || !body.slug?.trim()) throw new BadRequestException('Title and slug are required'); try { const data = await this.prisma.article.update({ where: { id }, data: { title: body.title.trim(), slug: body.slug.trim(), excerpt: body.excerpt?.trim(), content: body.content ?? '', categoryId: body.category_id ? Number(body.category_id) : null, imageId: body.image_id ? Number(body.image_id) : null, status: ['draft', 'published', 'archived'].includes(body.status) ? body.status : 'draft', isFeatured: Boolean(body.is_featured), publishedAt: body.status === 'published' ? new Date() : null } }); return { success: true, data }; } catch { throw new NotFoundException('Article not found'); } }
  async publishArticle(id: number) { try { await this.prisma.article.update({ where: { id }, data: { status: 'published', publishedAt: new Date() } }); return { success: true }; } catch { throw new NotFoundException('Article not found'); } }
  async deleteArticle(id: number) { try { await this.prisma.article.delete({ where: { id } }); return { success: true }; } catch { throw new NotFoundException('Article not found'); } }

  async media(page: number, limit: number) { const safePage = Math.max(1, page || 1); const safeLimit = Math.min(200, Math.max(1, limit || 50)); const [data, total] = await Promise.all([this.prisma.media.findMany({ orderBy: { createdAt: 'desc' }, skip: (safePage - 1) * safeLimit, take: safeLimit }), this.prisma.media.count()]); return { success: true, data, total, page: safePage, limit: safeLimit }; }
  async deleteMedia(id: number) { const media = await this.prisma.media.findUnique({ where: { id } }); if (!media) throw new NotFoundException('Media not found'); await this.prisma.$transaction([this.prisma.article.updateMany({ where: { imageId: id }, data: { imageId: null } }), this.prisma.media.delete({ where: { id } })]); return { success: true }; }
}