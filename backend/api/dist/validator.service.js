"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ValidatorService = exports.VERIFICATION_TIME = exports.VERTEX_SHADER = exports.FRAGMENT_HEADER = void 0;
const common_1 = require("@nestjs/common");
/**
 * Must stay byte-identical to the frontend's fragmentShaderHeader / vertexShaderSource.
 * Source of truth: frontend/scripts/shaderFunctions.js.
 */
exports.FRAGMENT_HEADER = '\nprecision mediump float;\nuniform vec2 u_resolution;\nuniform float u_time;\n\n';
exports.VERTEX_SHADER = '\n  attribute vec4 aVertexPosition;\n  precision mediump float;\n  void main() {\n    gl_Position = aVertexPosition;\n  }\n';
exports.VERIFICATION_TIME = 20.0;
let ValidatorService = class ValidatorService {
    log = new common_1.Logger('ValidatorService');
    url = process.env.VALIDATOR_URL || 'http://validator:3000/execute-shader';
    key = process.env.VALIDATOR_KEY || '';
    connectTimeoutMs = parseInt(process.env.VALIDATOR_CONNECT_TIMEOUT_MS || '2000', 10);
    readTimeoutMs = parseInt(process.env.VALIDATOR_READ_TIMEOUT_MS || '15000', 10);
    /** vertexShader+fragmentShader+time are the EXACT bytes sent to the validator. */
    async executeShader(vertexShader, fragmentShader, time) {
        const controller = new AbortController();
        const totalTimeout = this.connectTimeoutMs + this.readTimeoutMs;
        const timer = setTimeout(() => controller.abort(), totalTimeout);
        try {
            const res = await fetch(this.url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    ...(this.key ? { 'X-Validator-Key': this.key } : {}),
                },
                body: JSON.stringify({ vertexShader, fragmentShader, time }),
                signal: controller.signal,
            });
            if (res.status === 400) {
                const text = await res.text().catch(() => '');
                return { ok: false, compileError: true, error: text || 'compile-failed' };
            }
            if (res.status === 504)
                return { ok: false, compileError: false, error: 'render-timeout' };
            if (res.status === 429)
                return { ok: false, compileError: false, error: 'validator-busy' };
            if (!res.ok)
                return { ok: false, compileError: false, error: `validator-${res.status}` };
            const body = await res.json().catch(() => ({}));
            if (typeof body.imageHash !== 'string' || body.imageHash.length === 0) {
                return { ok: false, compileError: false, error: 'malformed-validator-response' };
            }
            return { ok: true, imageHash: body.imageHash };
        }
        catch (err) {
            const msg = err && err.name === 'AbortError' ? 'validator-timeout' : (err && err.message) || 'validator-unreachable';
            this.log.warn(`executeShader failed: ${msg}`);
            return { ok: false, compileError: false, error: msg };
        }
        finally {
            clearTimeout(timer);
        }
    }
};
exports.ValidatorService = ValidatorService;
exports.ValidatorService = ValidatorService = __decorate([
    (0, common_1.Injectable)()
], ValidatorService);
