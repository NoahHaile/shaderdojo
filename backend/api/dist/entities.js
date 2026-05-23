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
Object.defineProperty(exports, "__esModule", { value: true });
exports.Attempt = exports.Comment = exports.Lesson = exports.Course = exports.Account = void 0;
const typeorm_1 = require("typeorm");
let Account = class Account {
    id;
    username;
    password;
    email;
    country;
    bio;
    createdAt;
};
exports.Account = Account;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], Account.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ unique: true }),
    __metadata("design:type", String)
], Account.prototype, "username", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Account.prototype, "password", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Account.prototype, "email", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Account.prototype, "country", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], Account.prototype, "bio", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ name: 'created_at' }),
    __metadata("design:type", Date)
], Account.prototype, "createdAt", void 0);
exports.Account = Account = __decorate([
    (0, typeorm_1.Entity)('account')
], Account);
let Course = class Course {
    id;
    slug;
    title;
    description;
    displayOrder;
    createdAt;
};
exports.Course = Course;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], Course.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ unique: true }),
    __metadata("design:type", String)
], Course.prototype, "slug", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Course.prototype, "title", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], Course.prototype, "description", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'display_order', default: 0 }),
    __metadata("design:type", Number)
], Course.prototype, "displayOrder", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ name: 'created_at' }),
    __metadata("design:type", Date)
], Course.prototype, "createdAt", void 0);
exports.Course = Course = __decorate([
    (0, typeorm_1.Entity)('course')
], Course);
let Lesson = class Lesson {
    id;
    course;
    slug;
    displayOrder;
    title;
    description;
    starterVertexShader;
    starterFragmentShader;
    canonicalFragmentShader;
    hashedAnswer;
    createdAt;
};
exports.Lesson = Lesson;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], Lesson.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => Course, { eager: true }),
    (0, typeorm_1.JoinColumn)({ name: 'course_id' }),
    __metadata("design:type", Course)
], Lesson.prototype, "course", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Lesson.prototype, "slug", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'display_order', default: 0 }),
    __metadata("design:type", Number)
], Lesson.prototype, "displayOrder", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Lesson.prototype, "title", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], Lesson.prototype, "description", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'starter_vertex_shader', type: 'text', nullable: true }),
    __metadata("design:type", String)
], Lesson.prototype, "starterVertexShader", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'starter_fragment_shader', type: 'text', nullable: true }),
    __metadata("design:type", String)
], Lesson.prototype, "starterFragmentShader", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'canonical_fragment_shader', type: 'text', nullable: true }),
    __metadata("design:type", String)
], Lesson.prototype, "canonicalFragmentShader", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'hashed_answer', nullable: true }),
    __metadata("design:type", String)
], Lesson.prototype, "hashedAnswer", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ name: 'created_at' }),
    __metadata("design:type", Date)
], Lesson.prototype, "createdAt", void 0);
exports.Lesson = Lesson = __decorate([
    (0, typeorm_1.Entity)('lesson')
], Lesson);
let Comment = class Comment {
    id;
    code;
    content;
    account;
    lesson;
    createdAt;
};
exports.Comment = Comment;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], Comment.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], Comment.prototype, "code", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 512, nullable: true }),
    __metadata("design:type", String)
], Comment.prototype, "content", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => Account, { eager: true, nullable: true, onDelete: 'SET NULL' }),
    (0, typeorm_1.JoinColumn)({ name: 'account' }),
    __metadata("design:type", Account)
], Comment.prototype, "account", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => Lesson, { onDelete: 'CASCADE' }),
    (0, typeorm_1.JoinColumn)({ name: 'lesson' }),
    __metadata("design:type", Lesson)
], Comment.prototype, "lesson", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ name: 'created_at' }),
    __metadata("design:type", Date)
], Comment.prototype, "createdAt", void 0);
exports.Comment = Comment = __decorate([
    (0, typeorm_1.Entity)('comment')
], Comment);
let Attempt = class Attempt {
    id;
    status;
    account;
    lesson;
    createdAt;
};
exports.Attempt = Attempt;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], Attempt.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Attempt.prototype, "status", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => Account, { onDelete: 'CASCADE' }),
    (0, typeorm_1.JoinColumn)({ name: 'account' }),
    __metadata("design:type", Account)
], Attempt.prototype, "account", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => Lesson, { onDelete: 'CASCADE' }),
    (0, typeorm_1.JoinColumn)({ name: 'lesson' }),
    __metadata("design:type", Lesson)
], Attempt.prototype, "lesson", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ name: 'created_at' }),
    __metadata("design:type", Date)
], Attempt.prototype, "createdAt", void 0);
exports.Attempt = Attempt = __decorate([
    (0, typeorm_1.Entity)('attempt')
], Attempt);
