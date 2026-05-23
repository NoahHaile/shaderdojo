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

@Module({
    imports: [
        TypeOrmModule.forRoot({
            type: 'postgres',
            url: process.env.SPRING_DATASOURCE_URL?.replace(/^jdbc:/, '') || 'postgresql://localhost:5432/shader_dojo',
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
    providers: [TokenService, ValidatorService, AdminGuard, JwtGuard],
})
export class AppModule {}
