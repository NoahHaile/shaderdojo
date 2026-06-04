import {
    BadRequestException, Body, Controller, Logger, NotFoundException, Param, Post, Res,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Response } from 'express';
import OpenAI from 'openai';
import { Lesson } from './entities';

interface ConciergeMessage {
    role: 'user' | 'assistant';
    content: string;
}

class ConciergeBody {
    messages: ConciergeMessage[];
    code?: string;
    compileError?: string;
}

const PERSONA = `You are Concierge, a guide for ShaderDojo learners.

Voice
Speak like an ancient astronomer who has watched the sky for years.
Calm. Warm. Brief. One short thought per sentence.
You may name colors, light, distance, and shapes the way a stargazer would.
The voice must not make the help vague. Stay specific.

The transformation
A fragment shader is one transformation:
  f(x, y) -> g(r, g, b, a)
The input is a point on the canvas: (x, y).
The output is a color: (r, g, b, a).
Center every explanation in this framing.
When asked what a line does, answer in terms of how it changes (x, y) or (r, g, b, a).

What you can do
You help the learner go past the solution.
- Explain a technique with plain words.
- Trace the code top to bottom for one chosen pixel. Plug in real numbers. Show each variable. End at the final color.
- Read a compile error. Point to the line. Say the cause in plain words.
- Suggest a small experiment to try.

Rules
- Never paste the full solution.
- Help the learner think. Do not solve it for them.
- Keep responses short. Grade 4 to 6 reading level.
- No headings. No emoji.
- Wrap inline code with backticks.
- For longer code, use a fenced glsl block.
- The available uniforms are u_resolution (vec2), u_time (float), u_image (sampler2D), u_image_resolution (vec2). The only per-pixel input is gl_FragCoord.xy. The output is gl_FragColor (vec4).`;

function stripHtml(html: string | null): string {
    if (!html) return '';
    return html
        .replace(/<[^>]*>/g, '')
        .replace(/&nbsp;/g, ' ')
        .replace(/&amp;/g, '&')
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>')
        .replace(/&quot;/g, '"')
        .replace(/&#39;/g, "'")
        .replace(/&mdash;/g, '—')
        .replace(/\s+/g, ' ')
        .trim();
}

@Controller('lessons')
export class ConciergeController {
    private readonly log = new Logger('Concierge');
    private readonly openai = new OpenAI({
        apiKey: process.env.OPENAI_API_KEY,
    });

    constructor(
        @InjectRepository(Lesson) private readonly lessons: Repository<Lesson>,
    ) {}

    @Post(':lessonId/concierge')
    async concierge(
        @Param('lessonId') lessonId: string,
        @Body() body: ConciergeBody,
        @Res() res: Response,
    ): Promise<void> {
        if (!body?.messages?.length) throw new BadRequestException('messages required');
        if (!process.env.OPENAI_API_KEY) {
            res.status(503).type('text/plain').send('Concierge is offline: OPENAI_API_KEY not set on the backend.');
            return;
        }

        const lesson = await this.lessons.findOne({ where: { id: lessonId } });
        if (!lesson) throw new NotFoundException('lesson not found');

        // Cap the code and error payloads so a runaway client cannot blow up tokens.
        const code = (body.code ?? '').slice(0, 4000);
        const codeBlock = `The learner's current code:\n\`\`\`glsl\n${code || '(empty)'}\n\`\`\``;
        const errorBlock = body.compileError
            ? `The learner's last compile failed. The WebGL info log:\n\`\`\`\n${body.compileError.slice(0, 2000)}\n\`\`\`\nIf the learner asks for help, read the error first. Point to the line. Say the cause in plain words.`
            : 'The learner\'s last compile succeeded. No compile error to read right now.';

        // Optional per-lesson author guidance (e.g. "go gentle, this step is hard").
        const hint = lesson.conciergeHint?.trim();
        const hintBlock = hint
            ? `Special guidance from the lesson author for this lesson — follow it:\n${hint}`
            : null;

        // OpenAI takes one combined system message. Concatenate the persona,
        // the lesson context, the optional per-lesson hint, and the volatile
        // code/error block.
        const systemPrompt = [
            PERSONA,
            '',
            `Lesson title: ${lesson.title}`,
            `Lesson description (plain text): ${stripHtml(lesson.description)}`,
            ...(hintBlock ? ['', hintBlock] : []),
            '',
            codeBlock,
            '',
            errorBlock,
        ].join('\n');

        const model = process.env.CONCIERGE_MODEL ?? 'gpt-5.4-nano';

        res.setHeader('Content-Type', 'text/plain; charset=utf-8');
        res.setHeader('Transfer-Encoding', 'chunked');
        res.setHeader('Cache-Control', 'no-cache');
        res.flushHeaders?.();

        try {
            const stream = await this.openai.chat.completions.create({
                model,
                stream: true,
                max_completion_tokens: 4096,
                messages: [
                    { role: 'system', content: systemPrompt },
                    ...body.messages.map(m => ({ role: m.role, content: m.content })),
                ],
            });

            for await (const chunk of stream) {
                const text = chunk.choices[0]?.delta?.content;
                if (text) res.write(text);
            }
            res.end();
        } catch (err: any) {
            const msg = err?.message ?? 'unknown error';
            this.log.warn(`Concierge call failed for lesson ${lessonId}: ${msg}`);
            if (!res.headersSent) {
                res.status(502).type('text/plain').send(`Concierge upstream error: ${msg}`);
            } else {
                res.write(`\n\n(the stream broke: ${msg})`);
                res.end();
            }
        }
    }
}
