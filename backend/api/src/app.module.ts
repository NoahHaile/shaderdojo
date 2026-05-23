import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Account, Attempt, Comment, Course, Lesson } from './entities';
import { AuthController } from './auth.controller';
import { CoursesController } from './courses.controller';
import { LessonsController } from './lessons.controller';
import { CommentsController } from './comments.controller';
import { AccountController } from './account.controller';
import { HealthController } from './health.controller';
import { TokenService } from './token.service';
import { ValidatorService } from './validator.service';
import { AdminGuard } from './admin.guard';
import { JwtGuard } from './jwt.guard';
import { OptionalJwt } from './optional-jwt';

/** Parse `jdbc:postgresql://host:port/db` into discrete options. We deliberately don't
 *  pass `url` to TypeORM because when both `url` and `username` are set, the underlying
 *  `pg` driver uses the URL exclusively for the startup packet and drops the username. */
function parseJdbcUrl(jdbc: string) {
    const u = new URL(jdbc.replace(/^jdbc:/, ''));
    return {
        host: u.hostname,
        port: parseInt(u.port || '5432', 10),
        database: u.pathname.replace(/^\//, '') || 'shader_dojo',
    };
}

@Module({
    imports: [
        TypeOrmModule.forRoot({
            type: 'postgres',
            ...parseJdbcUrl(process.env.SPRING_DATASOURCE_URL || 'jdbc:postgresql://db:5432/shader_dojo'),
            username: process.env.SPRING_DATASOURCE_USERNAME,
            password: process.env.SPRING_DATASOURCE_PASSWORD,
            entities: [Account, Course, Lesson, Comment, Attempt],
            synchronize: false,
            logging: false,
        }),
        TypeOrmModule.forFeature([Account, Course, Lesson, Comment, Attempt]),
        JwtModule.register({
            global: true,
            secret: process.env.JWT_KEY,
            signOptions: { algorithm: 'HS256' },
            verifyOptions: { algorithms: ['HS256'] },
        }),
    ],
    controllers: [
        AuthController,
        CoursesController,
        LessonsController,
        CommentsController,
        AccountController,
        HealthController,
    ],
    providers: [TokenService, ValidatorService, AdminGuard, JwtGuard, OptionalJwt],
})
export class AppModule {}
