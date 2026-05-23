import { Injectable, Logger } from '@nestjs/common';

/**
 * Must stay byte-identical to the frontend's fragmentShaderHeader / vertexShaderSource.
 * Source of truth: frontend/scripts/shaderFunctions.js.
 */
export const FRAGMENT_HEADER =
    '\nprecision mediump float;\nuniform vec2 u_resolution;\nuniform float u_time;\n\n';

export const VERTEX_SHADER =
    '\n  attribute vec4 aVertexPosition;\n  precision mediump float;\n  void main() {\n    gl_Position = aVertexPosition;\n  }\n';

export const VERIFICATION_TIME = 20.0;

export interface ValidatorResult {
    ok: boolean;
    imageHash?: string;
    compileError?: boolean;
    error?: string;
}

@Injectable()
export class ValidatorService {
    private readonly log = new Logger('ValidatorService');
    private readonly url = process.env.VALIDATOR_URL || 'http://validator:3000/execute-shader';
    private readonly key = process.env.VALIDATOR_KEY || '';
    private readonly connectTimeoutMs = parseInt(process.env.VALIDATOR_CONNECT_TIMEOUT_MS || '2000', 10);
    private readonly readTimeoutMs = parseInt(process.env.VALIDATOR_READ_TIMEOUT_MS || '15000', 10);

    /** vertexShader+fragmentShader+time are the EXACT bytes sent to the validator. */
    async executeShader(vertexShader: string, fragmentShader: string, time: number): Promise<ValidatorResult> {
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
            if (res.status === 504) return { ok: false, compileError: false, error: 'render-timeout' };
            if (res.status === 429) return { ok: false, compileError: false, error: 'validator-busy' };
            if (!res.ok) return { ok: false, compileError: false, error: `validator-${res.status}` };

            const body: any = await res.json().catch(() => ({}));
            if (typeof body.imageHash !== 'string' || body.imageHash.length === 0) {
                return { ok: false, compileError: false, error: 'malformed-validator-response' };
            }
            return { ok: true, imageHash: body.imageHash };
        } catch (err: any) {
            const msg = err && err.name === 'AbortError' ? 'validator-timeout' : (err && err.message) || 'validator-unreachable';
            this.log.warn(`executeShader failed: ${msg}`);
            return { ok: false, compileError: false, error: msg };
        } finally {
            clearTimeout(timer);
        }
    }
}
