import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { StreamsController } from './streams.controller';
import { StreamsService } from './streams.service';

@Module({ imports: [AuthModule], controllers: [StreamsController], providers: [StreamsService] })
export class StreamsModule {}