import { Body, Controller, Get, Put, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { UserService } from './user.service';

@Controller('user')
@UseGuards(JwtAuthGuard)
export class UserController {
  constructor(private readonly users: UserService) {}

  @Get('profile') profile(@Req() req: any) { return this.users.profile(req.user.id); }
  @Put('profile') update(@Req() req: any, @Body() body: { name?: string; bio?: string; avatar_url?: string }) { return this.users.update(req.user.id, body); }
}