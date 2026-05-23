"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const typeorm_1 = require("@nestjs/typeorm");
const entities_1 = require("./entities");
const auth_controller_1 = require("./auth.controller");
const courses_controller_1 = require("./courses.controller");
const lessons_controller_1 = require("./lessons.controller");
const comments_controller_1 = require("./comments.controller");
const account_controller_1 = require("./account.controller");
const health_controller_1 = require("./health.controller");
const token_service_1 = require("./token.service");
const validator_service_1 = require("./validator.service");
const admin_guard_1 = require("./admin.guard");
const jwt_guard_1 = require("./jwt.guard");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            typeorm_1.TypeOrmModule.forRoot({
                type: 'postgres',
                url: process.env.SPRING_DATASOURCE_URL?.replace(/^jdbc:/, '') || 'postgresql://localhost:5432/shader_dojo',
                username: process.env.SPRING_DATASOURCE_USERNAME,
                password: process.env.SPRING_DATASOURCE_PASSWORD,
                entities: [entities_1.Account, entities_1.Course, entities_1.Lesson, entities_1.Comment, entities_1.Attempt],
                synchronize: false,
                logging: false,
            }),
            typeorm_1.TypeOrmModule.forFeature([entities_1.Account, entities_1.Course, entities_1.Lesson, entities_1.Comment, entities_1.Attempt]),
            jwt_1.JwtModule.register({
                global: true,
                secret: process.env.JWT_KEY,
                signOptions: { algorithm: 'HS256' },
                verifyOptions: { algorithms: ['HS256'] },
            }),
        ],
        controllers: [
            auth_controller_1.AuthController,
            courses_controller_1.CoursesController,
            lessons_controller_1.LessonsController,
            comments_controller_1.CommentsController,
            account_controller_1.AccountController,
            health_controller_1.HealthController,
        ],
        providers: [token_service_1.TokenService, validator_service_1.ValidatorService, admin_guard_1.AdminGuard, jwt_guard_1.JwtGuard],
    })
], AppModule);
