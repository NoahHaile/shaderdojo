import {
    BadRequestException, Body, ConflictException, Controller, HttpCode, InternalServerErrorException,
    Logger, Post, UnauthorizedException,
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
    private readonly log = new Logger('AuthController');

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
        } catch (e: any) {
            const code   = e?.code ?? e?.driverError?.code;
            const detail = e?.detail ?? e?.driverError?.detail;
            const constraint = e?.constraint ?? e?.driverError?.constraint;
            const table  = e?.table ?? e?.driverError?.table;
            // Log every failure with enough context to identify the constraint.
            this.log.error(
                `register failed username=${body.username} code=${code} ` +
                `table=${table} constraint=${constraint} detail=${detail} message=${e?.message}`,
            );
            // Only a unique_violation (23505) on the username constraint should look
            // like a 409 to the client; anything else is a real server error.
            if (code === '23505') {
                throw new ConflictException('Username already exists');
            }
            throw new InternalServerErrorException('Registration failed.');
        }
        return this.tokens.issue(account.id, 'user');
    }
}
