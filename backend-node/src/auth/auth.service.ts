import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../database/prisma.service';
import { createHash, randomBytes } from 'node:crypto';
import * as argon2 from 'argon2';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

type AuthUser = { id: number; name: string; email: string; role: string; userCode?: string };

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  async register(dto: RegisterDto) {
    const email = dto.email.trim().toLowerCase();
    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) throw new ConflictException('Email is already registered');
    const createdUser = await this.prisma.user.create({
      data: {
        name: (dto.name ?? dto.username ?? '').trim(),
        email,
        passwordHash: await argon2.hash(dto.password),
        role: 'subscriber',
        city: dto.city?.trim() || null,
        state: dto.state?.trim() || null,
      },
    });

    const userCode = this.buildUserCode(createdUser.id, createdUser.city, createdUser.state, email);
    const user = await this.prisma.user.update({ where: { id: createdUser.id }, data: { userCode } });

    return this.issueTokens({ id: user.id, name: user.name, email: user.email, role: user.role, userCode: user.userCode ?? undefined });
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({ where: { email: dto.email.trim().toLowerCase() } });
    if (!user || !user.isActive || !(await argon2.verify(user.passwordHash, dto.password))) {
      throw new UnauthorizedException('Invalid credentials');
    }
    return this.issueTokens({ id: user.id, name: user.name, email: user.email, role: user.role, userCode: user.userCode ?? undefined });
  }

  async refresh(refreshToken: string) {
    const tokenHash = createHash('sha256').update(refreshToken).digest('hex');
    const token = await this.prisma.refreshToken.findUnique({ where: { tokenHash }, include: { user: true } });
    if (!token || token.expiresAt <= new Date() || !token.user.isActive) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }
    await this.prisma.refreshToken.delete({ where: { id: token.id } });
    return this.issueTokens({
      id: token.user.id,
      name: token.user.name,
      email: token.user.email,
      role: token.user.role,
      userCode: token.user.userCode ?? undefined,
    });
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

  private async issueTokens(user: AuthUser) {
    const accessToken = await this.jwt.signAsync(user, {
      secret: this.config.getOrThrow<string>('JWT_ACCESS_SECRET'),
      expiresIn: '15m',
    });
    const refreshToken = randomBytes(48).toString('hex');
    await this.prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash: createHash('sha256').update(refreshToken).digest('hex'),
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      },
    });
    return { success: true, user, token: accessToken, accessToken, refreshToken };
  }
}