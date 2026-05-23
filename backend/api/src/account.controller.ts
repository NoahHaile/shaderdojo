import {
    BadRequestException, Body, ConflictException, Controller, Get, HttpCode, NotFoundException,
    Param, Post, Req, UnauthorizedException, UseGuards,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { Account, Attempt, AttemptStatus } from './entities';
import { JwtGuard } from './jwt.guard';

class AccountResponseDto {
    username: string; email: string | null; country: string | null; bio: string | null;
}
class AttemptResponseDto { count: number; status: AttemptStatus; }

class ProfileRequest { email?: string; country?: string; bio?: string; }
class AccountRequest { username: string; password: string; oldPassword: string; }

@Controller('account')
@UseGuards(JwtGuard)
export class AccountController {
    constructor(
        @InjectRepository(Account) private readonly accounts: Repository<Account>,
        @InjectRepository(Attempt) private readonly attempts: Repository<Attempt>,
    ) {}

    @Get()
    async self(@Req() req: any): Promise<AccountResponseDto> {
        const a = await this.accounts.findOne({ where: { id: req.userId } });
        if (!a) throw new NotFoundException();
        return {
            username: a.username, email: a.email ?? null,
            country: a.country ?? null, bio: a.bio ?? null,
        };
    }

    @Get('verify_account')
    async verify(@Req() req: any): Promise<boolean> {
        const exists = await this.accounts.exists({ where: { id: req.userId } });
        if (!exists) throw new NotFoundException();
        return true;
    }

    @Get('status/:lessonId')
    async status(@Param('lessonId') lessonId: string, @Req() req: any): Promise<AttemptResponseDto> {
        const rows = await this.attempts.find({
            where: { account: { id: req.userId }, lesson: { id: lessonId } },
        });
        if (rows.length === 0) return { count: 0, status: 'UNATTEMPTED' };
        const anySuccess = rows.some(r => r.status === 'SUCCESSFUL');
        return { count: rows.length, status: anySuccess ? 'SUCCESSFUL' : 'FAILED' };
    }

    /* Comment posting moved to POST /comments/:lessonId (CommentsController),
       which accepts both signed-in and anonymous users. */

    @Post('profile_info')
    @HttpCode(200)
    async updateProfile(@Body() body: ProfileRequest, @Req() req: any): Promise<string> {
        const a = await this.accounts.findOne({ where: { id: req.userId } });
        if (!a) throw new UnauthorizedException();
        if (body.email != null) a.email = body.email;
        if (body.country != null) a.country = body.country;
        if (body.bio != null) a.bio = body.bio;
        await this.accounts.save(a);
        return 'Profile updated';
    }

    @Post('account_info')
    @HttpCode(200)
    async updateAccount(@Body() body: AccountRequest, @Req() req: any): Promise<string> {
        const a = await this.accounts.findOne({ where: { id: req.userId } });
        if (!a) throw new UnauthorizedException();
        if (!body?.oldPassword || !body?.password || !body?.username) throw new BadRequestException();
        const ok = await bcrypt.compare(body.oldPassword, a.password);
        if (!ok) throw new UnauthorizedException('Incorrect password');
        a.username = body.username;
        a.password = await bcrypt.hash(body.password, 10);
        try {
            await this.accounts.save(a);
        } catch {
            throw new ConflictException('Username already exists');
        }
        return 'Account updated';
    }
}
