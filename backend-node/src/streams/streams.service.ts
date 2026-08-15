import { Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Prisma, type LiveStream, StreamStatus } from '@prisma/client';
import { createHash, randomBytes } from 'node:crypto';
import { PrismaService } from '../database/prisma.service';
import { CreateStreamDto } from './dto/create-stream.dto';
import { UpdateStreamDto } from './dto/update-stream.dto';

type StreamResponse = Omit<LiveStream, 'id' | 'startedById' | 'streamKeyHash'> & {
  id: string;
  startedById: number;
  streamKey?: string;
  ingestUrl?: string;
  whipUrl?: string;
};

@Injectable()
export class StreamsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {}

  async listActive(): Promise<StreamResponse[]> {
    const streams = await this.prisma.liveStream.findMany({
      where: { status: StreamStatus.LIVE },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
    return streams.map((stream: LiveStream) => this.toResponse(stream));
  }

  async create(dto: CreateStreamDto, startedById: number): Promise<StreamResponse> {
    const streamKey = randomBytes(32).toString('hex');
    const pathName = `news-${streamKey}`;
    const hlsUrl = (this.config.get<string>('MEDIA_HLS_URL') ?? 'http://127.0.0.1:8888').replace(/\/$/, '');
    const whipUrl = (this.config.get<string>('MEDIA_WHIP_URL') ?? 'http://127.0.0.1:8889').replace(/\/$/, '');
    const playbackUrl = `${hlsUrl}/${pathName}/index.m3u8`;
    const stream = await this.prisma.liveStream.create({
      data: {
        title: dto.title.trim(),
        description: dto.description?.trim(),
        streamKeyHash: createHash('sha256').update(streamKey).digest('hex'),
        pathName,
        playbackUrl,
        startedById,
      },
    });
    return {
      ...this.toResponse(stream),
      streamKey,
      ingestUrl: (this.config.get<string>('MEDIA_INGEST_URL') ?? 'rtmp://127.0.0.1:1935').replace(/\/$/, ''),
      whipUrl: `${whipUrl}/${pathName}/whip`,
    };
  }

  async update(id: bigint, dto: UpdateStreamDto, startedById: number): Promise<StreamResponse> {
    const timestamp = dto.status === StreamStatus.LIVE ? { startedAt: new Date() } : { endedAt: new Date() };
    try {
      const stream = await this.prisma.liveStream.update({
        where: { id, startedById },
        data: { status: dto.status, ...timestamp },
      });
      return this.toResponse(stream);
    } catch (error: unknown) {
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2025') {
        throw new NotFoundException('Stream not found or not owned by the current user');
      }
      throw error;
    }
  }

  private toResponse(stream: LiveStream): StreamResponse {
    return {
      id: stream.id.toString(),
      title: stream.title,
      description: stream.description,
      status: stream.status,
      playbackUrl: stream.playbackUrl,
      pathName: stream.pathName,
      startedById: stream.startedById,
      startedAt: stream.startedAt,
      endedAt: stream.endedAt,
      createdAt: stream.createdAt,
      updatedAt: stream.updatedAt,
    };
  }
}