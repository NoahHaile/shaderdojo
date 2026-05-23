import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
    const jwtKey = process.env.JWT_KEY;
    if (!jwtKey || Buffer.byteLength(jwtKey, 'utf8') < 32) {
        console.error('FATAL: JWT_KEY must be set and at least 32 bytes (UTF-8).');
        process.exit(1);
    }

    const app = await NestFactory.create(AppModule, { cors: false });
    // Note: NOT enabling `whitelist: true` because the DTO classes in this codebase
    // are plain TypeScript types without class-validator decorators. Whitelist mode
    // would strip every body field, surfacing as 401/404 errors in controllers that
    // null-check inputs. If we adopt class-validator across all DTOs later, this
    // can be turned back on.
    app.useGlobalPipes(new ValidationPipe({ transform: true }));

    const corsRaw = (process.env.CORS_ALLOWED_ORIGINS || '').trim();
    if (corsRaw.length > 0) {
        const origins = corsRaw.split(',').map(s => s.trim()).filter(Boolean);
        app.enableCors({
            origin: origins,
            methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
            allowedHeaders: ['Authorization', 'Content-Type', 'Admin-Authorization'],
        });
    } else {
        app.enableCors({
            origin: true,
            methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
            allowedHeaders: ['Authorization', 'Content-Type', 'Admin-Authorization'],
        });
    }

    const port = parseInt(process.env.PORT || '8080', 10);
    await app.listen(port);
    console.log(`API listening on :${port}`);
}

bootstrap().catch((err) => {
    console.error('Bootstrap failed:', err);
    process.exit(1);
});
