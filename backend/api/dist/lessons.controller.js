"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.LessonsController = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const entities_1 = require("./entities");
const admin_guard_1 = require("./admin.guard");
const jwt_guard_1 = require("./jwt.guard");
const validator_service_1 = require("./validator.service");
const crypto_1 = require("crypto");
class LessonDto {
    id;
    courseId;
    courseSlug;
    courseTitle;
    slug;
    title;
    displayOrder;
    description;
    starterVertexShader;
    starterFragmentShader;
    verified;
}
class LessonSolutionDto {
    id;
    title;
    canonicalFragmentShader;
    starterVertexShader;
}
class VerifyLessonBody {
    lessonId;
    vertexShader; // ignored — server uses canonical VERTEX_SHADER
    fragmentShader;
    time; // ignored — server uses VERIFICATION_TIME
}
class CreateLessonBody {
    courseId;
    slug;
    displayOrder;
    title;
    description;
    starterVertexShader;
    starterFragmentShader;
    canonicalFragmentShader;
    hashedAnswer;
}
class UpdateLessonBody extends CreateLessonBody {
} // partial; all fields optional in practice
function toDto(l) {
    return {
        id: l.id,
        courseId: l.course?.id ?? null,
        courseSlug: l.course?.slug ?? null,
        courseTitle: l.course?.title ?? null,
        slug: l.slug, title: l.title, displayOrder: l.displayOrder,
        description: l.description ?? null,
        starterVertexShader: l.starterVertexShader ?? null,
        starterFragmentShader: l.starterFragmentShader ?? null,
        verified: !!l.hashedAnswer,
    };
}
function equalsConstantTime(a, b) {
    const ab = Buffer.from(a, 'utf8');
    const bb = Buffer.from(b, 'utf8');
    if (ab.length !== bb.length)
        return false;
    return (0, crypto_1.timingSafeEqual)(ab, bb);
}
let LessonsController = class LessonsController {
    lessons;
    courses;
    accounts;
    attempts;
    validator;
    log = new common_1.Logger('LessonsController');
    constructor(lessons, courses, accounts, attempts, validator) {
        this.lessons = lessons;
        this.courses = courses;
        this.accounts = accounts;
        this.attempts = attempts;
        this.validator = validator;
    }
    async get(id) {
        const l = await this.lessons.findOne({ where: { id } });
        if (!l)
            throw new common_1.NotFoundException();
        return toDto(l);
    }
    async getSolution(id) {
        const l = await this.lessons.findOne({ where: { id } });
        if (!l)
            throw new common_1.NotFoundException();
        return {
            id: l.id, title: l.title,
            canonicalFragmentShader: l.canonicalFragmentShader ?? null,
            starterVertexShader: l.starterVertexShader ?? null,
        };
    }
    async verify(body, req) {
        if (!body?.lessonId || !body?.fragmentShader)
            throw new common_1.BadRequestException('Invalid request.');
        const account = await this.accounts.findOne({ where: { id: req.userId } });
        if (!account)
            throw new common_1.UnauthorizedException('Account not found.');
        const lesson = await this.lessons.findOne({ where: { id: body.lessonId } });
        if (!lesson)
            throw new common_1.NotFoundException('Lesson not found.');
        if (!lesson.hashedAnswer) {
            throw new common_1.BadRequestException("This lesson isn't graded yet — try again after the admin runs the hash sync.");
        }
        const result = await this.validator.executeShader(validator_service_1.VERTEX_SHADER, body.fragmentShader, validator_service_1.VERIFICATION_TIME);
        if (!result.ok) {
            if (result.compileError)
                throw new common_1.BadRequestException('Shader compile error.');
            this.log.warn(`Validator error for lesson ${lesson.id}: ${result.error}`);
            throw new common_1.BadGatewayException('Validator unavailable.');
        }
        const correct = equalsConstantTime(result.imageHash, lesson.hashedAnswer);
        const attempt = this.attempts.create({
            status: correct ? 'SUCCESSFUL' : 'FAILED',
            account, lesson,
        });
        await this.attempts.save(attempt);
        if (!correct)
            throw new common_1.BadRequestException('Incorrect.');
        return 'Correct.';
    }
    /**
     * Admin-only batch endpoint. Renders every lesson's canonical shader through the validator
     * and stores the resulting imageHash. Idempotent.
     */
    async recomputeHashes() {
        const updated = [];
        const skipped = [];
        const failed = [];
        const all = await this.lessons.find();
        for (const lesson of all) {
            const body = lesson.canonicalFragmentShader;
            if (!body || body.trim().length === 0) {
                skipped.push({ id: lesson.id, title: lesson.title, reason: 'no canonical shader' });
                continue;
            }
            const result = await this.validator.executeShader(validator_service_1.VERTEX_SHADER, validator_service_1.FRAGMENT_HEADER + body, validator_service_1.VERIFICATION_TIME);
            if (!result.ok) {
                failed.push({ id: lesson.id, title: lesson.title, error: result.error });
                continue;
            }
            lesson.hashedAnswer = result.imageHash;
            await this.lessons.save(lesson);
            updated.push({ id: lesson.id, title: lesson.title, hash: result.imageHash });
        }
        return { updated, skipped, failed, verificationTime: validator_service_1.VERIFICATION_TIME };
    }
    async create(body) {
        if (!body?.courseId || !body?.slug || !body?.title)
            throw new common_1.BadRequestException();
        const course = await this.courses.findOne({ where: { id: body.courseId } });
        if (!course)
            throw new common_1.NotFoundException();
        const l = this.lessons.create({
            course, slug: body.slug,
            displayOrder: body.displayOrder ?? 0,
            title: body.title, description: body.description ?? null,
            starterVertexShader: body.starterVertexShader ?? null,
            starterFragmentShader: body.starterFragmentShader ?? null,
            canonicalFragmentShader: body.canonicalFragmentShader ?? null,
            hashedAnswer: body.hashedAnswer ?? null,
        });
        return toDto(await this.lessons.save(l));
    }
    async update(id, body) {
        const l = await this.lessons.findOne({ where: { id } });
        if (!l)
            throw new common_1.NotFoundException();
        if (body.slug != null)
            l.slug = body.slug;
        if (body.displayOrder != null)
            l.displayOrder = body.displayOrder;
        if (body.title != null)
            l.title = body.title;
        if (body.description != null)
            l.description = body.description;
        if (body.starterVertexShader != null)
            l.starterVertexShader = body.starterVertexShader;
        if (body.starterFragmentShader != null)
            l.starterFragmentShader = body.starterFragmentShader;
        if (body.canonicalFragmentShader != null)
            l.canonicalFragmentShader = body.canonicalFragmentShader;
        if (body.hashedAnswer != null)
            l.hashedAnswer = body.hashedAnswer;
        return toDto(await this.lessons.save(l));
    }
    async remove(id) {
        const l = await this.lessons.findOne({ where: { id } });
        if (!l)
            throw new common_1.NotFoundException();
        await this.lessons.remove(l);
    }
};
exports.LessonsController = LessonsController;
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LessonsController.prototype, "get", null);
__decorate([
    (0, common_1.Get)(':id/solution'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LessonsController.prototype, "getSolution", null);
__decorate([
    (0, common_1.Post)('verify'),
    (0, common_1.UseGuards)(jwt_guard_1.JwtGuard),
    (0, common_1.HttpCode)(200),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [VerifyLessonBody, Object]),
    __metadata("design:returntype", Promise)
], LessonsController.prototype, "verify", null);
__decorate([
    (0, common_1.Post)('recompute-hashes'),
    (0, common_1.UseGuards)(admin_guard_1.AdminGuard),
    (0, common_1.HttpCode)(200),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], LessonsController.prototype, "recomputeHashes", null);
__decorate([
    (0, common_1.Post)(),
    (0, common_1.UseGuards)(admin_guard_1.AdminGuard),
    (0, common_1.HttpCode)(201),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [CreateLessonBody]),
    __metadata("design:returntype", Promise)
], LessonsController.prototype, "create", null);
__decorate([
    (0, common_1.Put)(':id'),
    (0, common_1.UseGuards)(admin_guard_1.AdminGuard),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], LessonsController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, common_1.UseGuards)(admin_guard_1.AdminGuard),
    (0, common_1.HttpCode)(204),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], LessonsController.prototype, "remove", null);
exports.LessonsController = LessonsController = __decorate([
    (0, common_1.Controller)('lessons'),
    __param(0, (0, typeorm_1.InjectRepository)(entities_1.Lesson)),
    __param(1, (0, typeorm_1.InjectRepository)(entities_1.Course)),
    __param(2, (0, typeorm_1.InjectRepository)(entities_1.Account)),
    __param(3, (0, typeorm_1.InjectRepository)(entities_1.Attempt)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        validator_service_1.ValidatorService])
], LessonsController);
