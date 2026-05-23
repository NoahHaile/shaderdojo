import {
    BadRequestException, Body, ConflictException, Controller, HttpCode, Post, UnauthorizedException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { Account } from './entities';
import { TokenService } from './token.service';

class LoginRequest { username: string; password: string; }
class RegisterRequest { email?: string; username: string; password: string; }

@Controller()
export class AuthController {
    constructor(
        @InjectRepository(Account) private readonly accounts: Repository<Account>,
        private readonly tokens: TokenService,
    ) {}

    @Post('login')
    @HttpCode(200)
    async login(@Body() body: LoginRequest): Promise<string> {
        if (!body?.username || !body?.password) throw new UnauthorizedException();
        const account = await this.accounts.findOne({
            where: [{ username: body.username }, { email: body.username }],
        });
        if (!account) throw new UnauthorizedException();
        const ok = await bcrypt.compare(body.password, account.password);
        if (!ok) throw new UnauthorizedException();
        return this.tokens.issue(account.id, 'user');
    }

    @Post('register')
    @HttpCode(200)
    async register(@Body() body: RegisterRequest): Promise<string> {
        if (!body?.username || !body?.password) {
            throw new BadRequestException('username and password are required');
        }
        const hashed = await bcrypt.hash(body.password, 10);
        const account = this.accounts.create({
            username: body.username,
            password: hashed,
            email: body.email ?? null,
        });
        try {
            await this.accounts.save(account);
        } catch {
            throw new ConflictException('Username already exists');
        }
        return this.tokens.issue(account.id, 'user');
    }
}
