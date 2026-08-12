import { BadRequestException, Controller, Get, Query } from '@nestjs/common';
import { NewsService } from './news.service';

@Controller()
export class NewsDiscoveryController {
  constructor(private readonly newsService: NewsService) {}

  @Get('search')
  search(@Query('q') query?: string) {
    if (!query?.trim()) throw new BadRequestException('Search query is required');
    return this.newsService.search(query.trim());
  }

  @Get('trending')
  trending(@Query('limit') limit = '10') {
    const parsedLimit = Number(limit);
    return this.newsService.trending(Math.min(20, Math.max(1, Number.isFinite(parsedLimit) ? parsedLimit : 10)));
  }
}
