import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { PrismaClient } from '@prisma/client';
import { AppModule } from './app.module';
import { ensureDefaultAdmin } from './config/seed-admin';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api/v1');
  app.enableCors();
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  const prisma = new PrismaClient();
  try {
    await ensureDefaultAdmin(prisma);
  } catch (error) {
    console.warn('Default admin bootstrap skipped:', error instanceof Error ? error.message : error);
  } finally {
    await prisma.$disconnect();
  }

  await app.listen(process.env.PORT ?? 3000);
}

void bootstrap();