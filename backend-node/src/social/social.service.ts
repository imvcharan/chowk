import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class SocialService {
  constructor(private readonly prisma: PrismaService) {}

  async bookmarks(userId: number, page: number, limit: number) {
    const items = await this.prisma.bookmark.findMany({ where: { userId }, include: { article: { include: { category: true, author: true, image: true } } }, orderBy: { createdAt: 'desc' }, skip: (page - 1) * limit, take: limit });
    return { success: true, data: items.map((item: any) => ({ ...item.article, description: item.article.excerpt, category_name: item.article.category?.name, author_name: item.article.author?.name, image_url: item.article.image?.url, bookmarked_at: item.createdAt })) };
  }

  async addBookmark(userId: number, articleId: number) {
    await this.ensureArticle(articleId);
    await this.prisma.bookmark.create({ data: { userId, articleId } });
    return { success: true };
  }

  async removeBookmark(userId: number, articleId: number) {
    await this.prisma.bookmark.deleteMany({ where: { userId, articleId } });
    return { success: true };
  }

  async likeStatus(userId: number, articleId: number) {
    const [count, like] = await Promise.all([this.prisma.like.count({ where: { articleId } }), this.prisma.like.findUnique({ where: { userId_articleId: { userId, articleId } } })]);
    return { success: true, data: { count, is_liked: Boolean(like) } };
  }

  async like(userId: number, articleId: number) {
    await this.ensureArticle(articleId);
    await this.prisma.like.create({ data: { userId, articleId } });
    return { success: true };
  }

  async unlike(userId: number, articleId: number) {
    await this.prisma.like.deleteMany({ where: { userId, articleId } });
    return { success: true };
  }

  async comments(articleId: number, page: number, limit: number) {
    const comments = await this.prisma.comment.findMany({ where: { articleId, isApproved: true }, include: { user: true }, orderBy: { createdAt: 'desc' }, skip: (page - 1) * limit, take: limit });
    return { success: true, data: comments.map((comment: any) => ({ id: comment.id, content: comment.content, created_at: comment.createdAt, likes_count: comment.likesCount, user_name: comment.user.name, user_avatar: comment.user.avatarUrl })) };
  }

  async addComment(userId: number, articleId: number, content: string) {
    await this.ensureArticle(articleId);
    await this.prisma.comment.create({ data: { userId, articleId, content: content.trim() } });
    return { success: true };
  }

  async removeComment(userId: number, id: number) {
    await this.prisma.comment.deleteMany({ where: { id, userId } });
    return { success: true };
  }

  private async ensureArticle(id: number) {
    if (!(await this.prisma.article.findUnique({ where: { id }, select: { id: true } }))) throw new NotFoundException('News article not found');
  }
}