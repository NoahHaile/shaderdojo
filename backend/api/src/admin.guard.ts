import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import { timingSafeEqual } from 'crypto';

@Injectable()
export class AdminGuard implements CanActivate {
    private readonly expected = Buffer.from(process.env.API_KEY || '', 'utf8');

    canActivate(ctx: ExecutionContext): boolean {
        const req = ctx.switchToHttp().getRequest();
        const provided = Buffer.from((req.headers['admin-authorization'] as string) || '', 'utf8');
        if (this.expected.length === 0) throw new UnauthorizedException();
        if (provided.length !== this.expected.length) throw new UnauthorizedException();
        if (!timingSafeEqual(provided, this.expected)) throw new UnauthorizedException();
        return true;
    }
}
