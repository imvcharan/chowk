import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { PrismaModule } from './database/prisma.module';
import { HealthController } from './health.controller';
import { StreamsModule } from './streams/streams.module';
import { CategoriesModule } from './categories/categories.module';
import { NewsModule } from './news/news.module';
import { SocialModule } from './social/social.module';
import { UserModule } from './user/user.module';
import { ReportsModule } from './reports/reports.module';
import { LiveReportsModule } from './live-reports/live-reports.module';
import { MediaModule } from './media/media.module';
import { AdminModule } from './admin/admin.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),
    PrismaModule,
    AuthModule,
    StreamsModule,
    CategoriesModule,
    NewsModule,
    SocialModule,
    UserModule,
    ReportsModule,
    LiveReportsModule,
    MediaModule,
    AdminModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}