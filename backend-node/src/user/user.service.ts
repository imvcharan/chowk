import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class UserService {
  constructor(private readonly prisma: PrismaService) {}

  async profile(id: number) {
    const user = await this.prisma.user.findUnique({ where: { id }, select: { id: true, name: true, email: true, role: true, avatarUrl: true, bio: true, createdAt: true } });
    if (!user) throw new NotFoundException('User not found');
    const [bookmarks, comments, likes] = await Promise.all([this.prisma.bookmark.count({ where: { userId: id } }), this.prisma.comment.count({ where: { userId: id } }), this.prisma.like.count({ where: { userId: id } })]);
    return { success: true, data: { ...user, bookmarks_count: bookmarks, comments_count: comments, likes_count: likes } };
  }

  update(id: number, input: { name?: string; bio?: string; avatar_url?: string }) {
    return this.prisma.user.update({ where: { id }, data: { name: input.name?.trim(), bio: input.bio?.trim(), avatarUrl: input.avatar_url?.trim() } }).then(() => ({ success: true }));
  }
}