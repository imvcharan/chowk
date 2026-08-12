import { Injectable, UnsupportedMediaTypeException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../database/prisma.service';
import { randomBytes } from 'node:crypto';
import { mkdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';

@Injectable()
export class MediaService {
  constructor(private readonly prisma: PrismaService, private readonly config: ConfigService) {}

  async save(file: Express.Multer.File) {
    const imageTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
    const videoTypes = ['video/mp4', 'video/quicktime', 'video/x-msvideo', 'video/x-matroska'];
    const maxSize = imageTypes.includes(file.mimetype) ? 5 * 1024 * 1024 : 100 * 1024 * 1024;
    if (![...imageTypes, ...videoTypes].includes(file.mimetype)) throw new UnsupportedMediaTypeException('Unsupported media type');
    if (file.size > maxSize) throw new UnsupportedMediaTypeException('File exceeds the allowed size');
    const uploadDir = this.config.get<string>('UPLOAD_DIR') ?? join(process.cwd(), 'uploads');
    await mkdir(uploadDir, { recursive: true });
    const extension = file.originalname.includes('.') ? file.originalname.slice(file.originalname.lastIndexOf('.')) : '';
    const name = `${randomBytes(12).toString('hex')}${extension}`;
    await writeFile(join(uploadDir, name), file.buffer);
    const publicBase = (this.config.get<string>('PUBLIC_MEDIA_URL') ?? 'http://127.0.0.1:3000/uploads').replace(/\/$/, '');
    const media = await this.prisma.media.create({ data: { fileName: name, url: `${publicBase}/${name}`, mime: file.mimetype, size: file.size } });
    return { success: true, url: media.url, data: media };
  }
}