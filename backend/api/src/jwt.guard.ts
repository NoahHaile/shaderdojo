import {
    CanActivate, ExecutionContext, Injectable, UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

export interface AuthedRequest extends Request {
    userId?: string;
}

@Injectable()
export class JwtGuard implements CanActivate {
    constructor(private readonly jwt: JwtService) {}

    async canActivate(ctx: ExecutionContext): Promise<boolean> {
        const req = ctx.switchToHttp().getRequest();
        const header = (req.headers['authorization'] as string) || '';
        if (!header.startsWith('Bearer ')) {
            throw new UnauthorizedException('Missing bearer token');
        }
        const token = header.slice('Bearer '.length).trim();
        try {
            const payload = await this.jwt.verifyAsync(token);
            if (!payload || typeof payload.sub !== 'string') {
                throw new UnauthorizedException('Malformed token');
            }
            req.userId = payload.sub;
            return true;
        } catch {
            throw new UnauthorizedException('Invalid token');
        }
    }
}
