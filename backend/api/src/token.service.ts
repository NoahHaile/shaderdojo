import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class TokenService {
    constructor(private readonly jwt: JwtService) {}

    async issue(userId: string, scope: string = 'user'): Promise<string> {
        const now = Math.floor(Date.now() / 1000);
        return this.jwt.signAsync({
            iss: 'self',
            sub: userId,
            iat: now,
            exp: now + 60 * 60 * 24 * 30, // 30 days, matches Spring TokenService
            scope,
        });
    }
}
