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
exports.CoursesController = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const entities_1 = require("./entities");
const admin_guard_1 = require("./admin.guard");
class CourseDto {
    id;
    slug;
    title;
    description;
    displayOrder;
}
class LessonSummaryDto {
    id;
    slug;
    title;
    displayOrder;
    verified;
}
class CourseDetailDto extends CourseDto {
    lessons;
}
class CreateCourseBody {
    slug;
    title;
    description;
    displayOrder;
}
function toSummary(l) {
    return {
        id: l.id, slug: l.slug, title: l.title,
        displayOrder: l.displayOrder, verified: !!l.hashedAnswer,
    };
}
let CoursesController = class CoursesController {
    courses;
    lessons;
    constructor(courses, lessons) {
        this.courses = courses;
        this.lessons = lessons;
    }
    /** GET /courses → all courses, each with nested lesson summaries. */
    async list() {
        const cs = await this.courses.find({ order: { displayOrder: 'ASC', title: 'ASC' } });
        const out = [];
        for (const c of cs) {
            const lessons = await this.lessons.find({
                where: { course: { id: c.id } },
                order: { displayOrder: 'ASC', title: 'ASC' },
            });
            out.push({
                id: c.id, slug: c.slug, title: c.title, description: c.description ?? null,
                displayOrder: c.displayOrder,
                lessons: lessons.map(toSummary),
            });
        }
        return out;
    }
    /** GET /courses/:slug → single course detail. */
    async detail(slug) {
        const c = await this.courses.findOne({ where: { slug } });
        if (!c)
            throw new common_1.NotFoundException();
        const lessons = await this.lessons.find({
            where: { course: { id: c.id } },
            order: { displayOrder: 'ASC', title: 'ASC' },
        });
        return {
            id: c.id, slug: c.slug, title: c.title, description: c.description ?? null,
            displayOrder: c.displayOrder,
            lessons: lessons.map(toSummary),
        };
    }
    async create(body) {
        if (!body?.slug || !body?.title)
            throw new common_1.BadRequestException();
        const c = this.courses.create({
            slug: body.slug, title: body.title,
            description: body.description ?? null,
            displayOrder: body.displayOrder ?? 0,
        });
        const saved = await this.courses.save(c);
        return {
            id: saved.id, slug: saved.slug, title: saved.title,
            description: saved.description ?? null, displayOrder: saved.displayOrder,
        };
    }
    async update(id, body) {
        const c = await this.courses.findOne({ where: { id } });
        if (!c)
            throw new common_1.NotFoundException();
        if (body.slug != null)
            c.slug = body.slug;
        if (body.title != null)
            c.title = body.title;
        if (body.description != null)
            c.description = body.description;
        if (body.displayOrder != null)
            c.displayOrder = body.displayOrder;
        const saved = await this.courses.save(c);
        return {
            id: saved.id, slug: saved.slug, title: saved.title,
            description: saved.description ?? null, displayOrder: saved.displayOrder,
        };
    }
    async remove(id) {
        const c = await this.courses.findOne({ where: { id } });
        if (!c)
            throw new common_1.NotFoundException();
        await this.courses.remove(c);
    }
};
exports.CoursesController = CoursesController;
__decorate([
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], CoursesController.prototype, "list", null);
__decorate([
    (0, common_1.Get)(':slug'),
    __param(0, (0, common_1.Param)('slug')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], CoursesController.prototype, "detail", null);
__decorate([
    (0, common_1.Post)(),
    (0, common_1.UseGuards)(admin_guard_1.AdminGuard),
    (0, common_1.HttpCode)(201),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [CreateCourseBody]),
    __metadata("design:returntype", Promise)
], CoursesController.prototype, "create", null);
__decorate([
    (0, common_1.Put)(':id'),
    (0, common_1.UseGuards)(admin_guard_1.AdminGuard),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], CoursesController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, common_1.UseGuards)(admin_guard_1.AdminGuard),
    (0, common_1.HttpCode)(204),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], CoursesController.prototype, "remove", null);
exports.CoursesController = CoursesController = __decorate([
    (0, common_1.Controller)('courses'),
    __param(0, (0, typeorm_1.InjectRepository)(entities_1.Course)),
    __param(1, (0, typeorm_1.InjectRepository)(entities_1.Lesson)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], CoursesController);
