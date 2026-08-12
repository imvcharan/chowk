import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { LiveReportsController } from './live-reports.controller';
import { LiveReportsService } from './live-reports.service';

@Module({ imports: [AuthModule], controllers: [LiveReportsController], providers: [LiveReportsService] })
export class LiveReportsModule {}