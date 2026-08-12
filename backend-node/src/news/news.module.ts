import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { NewsController } from './news.controller';
import { NewsDiscoveryController } from './news-discovery.controller';
import { NewsService } from './news.service';

@Module({ imports: [AuthModule], controllers: [NewsController, NewsDiscoveryController], providers: [NewsService] })
export class NewsModule {}