import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

/**
 * Pulls a Bearer token off the request if one is present and decodes it; if
 * absent or invalid, returns null. Use in endpoints where auth is optional —
 * authed users get personalized behavior, anonymous users still get a 200.
 */
@Injectable()
export class OptionalJwt {
    constructor(private readonly jwt: JwtService) {}

    /** Returns the userId from a valid Bearer token, or null. Never throws. */
    async userIdFrom(req: any): Promise<string | null> {
        const header = (req?.headers?.authorization as string | undefined) ?? '';
        if (!header.startsWith('Bearer ')) return null;
        const token = header.slice('Bearer '.length).trim();
        if (!token) return null;
        try {
            const payload = await this.jwt.verifyAsync(token);
            return typeof payload?.sub === 'string' ? payload.sub : null;
        } catch {
            return null;
        }
    }
}
