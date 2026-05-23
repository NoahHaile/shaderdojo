"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdminGuard = void 0;
const common_1 = require("@nestjs/common");
const crypto_1 = require("crypto");
let AdminGuard = class AdminGuard {
    expected = Buffer.from(process.env.API_KEY || '', 'utf8');
    canActivate(ctx) {
        const req = ctx.switchToHttp().getRequest();
        const provided = Buffer.from(req.headers['admin-authorization'] || '', 'utf8');
        if (this.expected.length === 0)
            throw new common_1.UnauthorizedException();
        if (provided.length !== this.expected.length)
            throw new common_1.UnauthorizedException();
        if (!(0, crypto_1.timingSafeEqual)(provided, this.expected))
            throw new common_1.UnauthorizedException();
        return true;
    }
};
exports.AdminGuard = AdminGuard;
exports.AdminGuard = AdminGuard = __decorate([
    (0, common_1.Injectable)()
], AdminGuard);
