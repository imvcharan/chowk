import { Body, Controller, Get, Param, Patch, Post, Req, UseGuards, ForbiddenException } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateStreamDto } from './dto/create-stream.dto';
import { UpdateStreamDto } from './dto/update-stream.dto';
import { StreamsService } from './streams.service';

@Controller('streams')
export class StreamsController {
  constructor(private readonly streamsService: StreamsService) {}

  @Get()
  list() {
    return this.streamsService.listActive();
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  create(@Body() dto: CreateStreamDto, @Req() request: { user: { id: number; role: string } }) {
    this.assertPublisher(request.user.role);
    return this.streamsService.create(dto, request.user.id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  update(@Param('id') id: string, @Body() dto: UpdateStreamDto, @Req() request: { user: { id: number; role: string } }) {
    this.assertPublisher(request.user.role);
    return this.streamsService.update(BigInt(id), dto, request.user.id);
  }

  private assertPublisher(role: string): void {
    if (!['admin', 'super_admin', 'editor', 'reporter'].includes(role)) {
      throw new ForbiddenException('Stream publishing is not allowed for this role');
    }
  }
}