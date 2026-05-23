"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AccountController = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const bcrypt = __importStar(require("bcryptjs"));
const entities_1 = require("./entities");
const jwt_guard_1 = require("./jwt.guard");
class AccountResponseDto {
    username;
    email;
    country;
    bio;
}
class AttemptResponseDto {
    count;
    status;
}
class CommentResponseDto {
    id;
    code;
    content;
    username;
}
class CommentRequest {
    code;
    content;
}
class ProfileRequest {
    email;
    country;
    bio;
}
class AccountRequest {
    username;
    password;
    oldPassword;
}
let AccountController = class AccountController {
    accounts;
    lessons;
    comments;
    attempts;
    constructor(accounts, lessons, comments, attempts) {
        this.accounts = accounts;
        this.lessons = lessons;
        this.comments = comments;
        this.attempts = attempts;
    }
    async self(req) {
        const a = await this.accounts.findOne({ where: { id: req.userId } });
        if (!a)
            throw new common_1.NotFoundException();
        return {
            username: a.username, email: a.email ?? null,
            country: a.country ?? null, bio: a.bio ?? null,
        };
    }
    async verify(req) {
        const exists = await this.accounts.exists({ where: { id: req.userId } });
        if (!exists)
            throw new common_1.NotFoundException();
        return true;
    }
    async status(lessonId, req) {
        const rows = await this.attempts.find({
            where: { account: { id: req.userId }, lesson: { id: lessonId } },
        });
        if (rows.length === 0)
            return { count: 0, status: 'UNATTEMPTED' };
        const anySuccess = rows.some(r => r.status === 'SUCCESSFUL');
        return { count: rows.length, status: anySuccess ? 'SUCCESSFUL' : 'FAILED' };
    }
    async createComment(lessonId, body, req) {
        const account = await this.accounts.findOne({ where: { id: req.userId } });
        if (!account)
            throw new common_1.UnauthorizedException();
        const lesson = await this.lessons.findOne({ where: { id: lessonId } });
        if (!lesson)
            throw new common_1.NotFoundException();
        const c = this.comments.create({
            code: body?.code ?? null, content: body?.content ?? null,
            account, lesson,
        });
        const saved = await this.comments.save(c);
        return {
            id: saved.id, code: saved.code ?? null, content: saved.content ?? null,
            username: account.username,
        };
    }
    async updateProfile(body, req) {
        const a = await this.accounts.findOne({ where: { id: req.userId } });
        if (!a)
            throw new common_1.UnauthorizedException();
        if (body.email != null)
            a.email = body.email;
        if (body.country != null)
            a.country = body.country;
        if (body.bio != null)
            a.bio = body.bio;
        await this.accounts.save(a);
        return 'Profile updated';
    }
    async updateAccount(body, req) {
        const a = await this.accounts.findOne({ where: { id: req.userId } });
        if (!a)
            throw new common_1.UnauthorizedException();
        if (!body?.oldPassword || !body?.password || !body?.username)
            throw new common_1.BadRequestException();
        const ok = await bcrypt.compare(body.oldPassword, a.password);
        if (!ok)
            throw new common_1.UnauthorizedException('Incorrect password');
        a.username = body.username;
        a.password = await bcrypt.hash(body.password, 10);
        try {
            await this.accounts.save(a);
        }
        catch {
            throw new common_1.ConflictException('Username already exists');
        }
        return 'Account updated';
    }
};
exports.AccountController = AccountController;
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], AccountController.prototype, "self", null);
__decorate([
    (0, common_1.Get)('verify_account'),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], AccountController.prototype, "verify", null);
__decorate([
    (0, common_1.Get)('status/:lessonId'),
    __param(0, (0, common_1.Param)('lessonId')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], AccountController.prototype, "status", null);
__decorate([
    (0, common_1.Post)('comment/:lessonId'),
    (0, common_1.HttpCode)(201),
    __param(0, (0, common_1.Param)('lessonId')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, CommentRequest, Object]),
    __metadata("design:returntype", Promise)
], AccountController.prototype, "createComment", null);
__decorate([
    (0, common_1.Post)('profile_info'),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [ProfileRequest, Object]),
    __metadata("design:returntype", Promise)
], AccountController.prototype, "updateProfile", null);
__decorate([
    (0, common_1.Post)('account_info'),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [AccountRequest, Object]),
    __metadata("design:returntype", Promise)
], AccountController.prototype, "updateAccount", null);
exports.AccountController = AccountController = __decorate([
    (0, common_1.Controller)('account'),
    (0, common_1.UseGuards)(jwt_guard_1.JwtGuard),
    __param(0, (0, typeorm_1.InjectRepository)(entities_1.Account)),
    __param(1, (0, typeorm_1.InjectRepository)(entities_1.Lesson)),
    __param(2, (0, typeorm_1.InjectRepository)(entities_1.Comment)),
    __param(3, (0, typeorm_1.InjectRepository)(entities_1.Attempt)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], AccountController);
