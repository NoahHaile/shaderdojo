"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("reflect-metadata");
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const app_module_1 = require("./app.module");
async function bootstrap() {
    const jwtKey = process.env.JWT_KEY;
    if (!jwtKey || Buffer.byteLength(jwtKey, 'utf8') < 32) {
        console.error('FATAL: JWT_KEY must be set and at least 32 bytes (UTF-8).');
        process.exit(1);
    }
    const app = await core_1.NestFactory.create(app_module_1.AppModule, { cors: false });
    app.useGlobalPipes(new common_1.ValidationPipe({ whitelist: true, transform: true }));
    const corsRaw = (process.env.CORS_ALLOWED_ORIGINS || '').trim();
    if (corsRaw.length > 0) {
        const origins = corsRaw.split(',').map(s => s.trim()).filter(Boolean);
        app.enableCors({
            origin: origins,
            methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
            allowedHeaders: ['Authorization', 'Content-Type', 'Admin-Authorization'],
        });
    }
    else {
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
