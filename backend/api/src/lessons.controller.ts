import {
    BadGatewayException, BadRequestException, Body, Controller, Delete, Get, HttpCode,
    Logger, NotFoundException, Param, Post, Put, Req, UnauthorizedException, UseGuards,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Account, Attempt, Course, Lesson } from './entities';
import { AdminGuard } from './admin.guard';
import { JwtGuard } from './jwt.guard';
import { FRAGMENT_HEADER, VERIFICATION_TIME, VERTEX_SHADER, ValidatorService } from './validator.service';
import { timingSafeEqual } from 'crypto';

class LessonDto {
    id: string; courseId: string | null; courseSlug: string | null; courseTitle: string | null;
    slug: string; title: string; displayOrder: number;
    description: string | null;
    starterVertexShader: string | null; starterFragmentShader: string | null;
    verified: boolean;
}

class LessonSolutionDto {
    id: string; title: string;
    canonicalFragmentShader: string | null; starterVertexShader: string | null;
}

class VerifyLessonBody {
    lessonId: string;
    vertexShader?: string;       // ignored — server uses canonical VERTEX_SHADER
    fragmentShader: string;
    time?: number;               // ignored — server uses VERIFICATION_TIME
}

class CreateLessonBody {
    courseId: string; slug: string; displayOrder?: number;
    title: string; description?: string;
    starterVertexShader?: string;
    starterFragmentShader?: string;
    canonicalFragmentShader?: string;
    hashedAnswer?: string;
}
class UpdateLessonBody extends CreateLessonBody {} // partial; all fields optional in practice

function toDto(l: Lesson): LessonDto {
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

function equalsConstantTime(a: string, b: string): boolean {
    const ab = Buffer.from(a, 'utf8'); const bb = Buffer.from(b, 'utf8');
    if (ab.length !== bb.length) return false;
    return timingSafeEqual(ab, bb);
}

@Controller('lessons')
export class LessonsController {
    private readonly log = new Logger('LessonsController');

    constructor(
        @InjectRepository(Lesson) private readonly lessons: Repository<Lesson>,
        @InjectRepository(Course) private readonly courses: Repository<Course>,
        @InjectRepository(Account) private readonly accounts: Repository<Account>,
        @InjectRepository(Attempt) private readonly attempts: Repository<Attempt>,
        private readonly validator: ValidatorService,
    ) {}

    @Get(':id')
    async get(@Param('id') id: string): Promise<LessonDto> {
        const l = await this.lessons.findOne({ where: { id } });
        if (!l) throw new NotFoundException();
        return toDto(l);
    }

    @Get(':id/solution')
    async getSolution(@Param('id') id: string): Promise<LessonSolutionDto> {
        const l = await this.lessons.findOne({ where: { id } });
        if (!l) throw new NotFoundException();
        return {
            id: l.id, title: l.title,
            canonicalFragmentShader: l.canonicalFragmentShader ?? null,
            starterVertexShader: l.starterVertexShader ?? null,
        };
    }

    @Post('verify')
    @UseGuards(JwtGuard)
    @HttpCode(200)
    async verify(@Body() body: VerifyLessonBody, @Req() req: any): Promise<string> {
        if (!body?.lessonId || !body?.fragmentShader) throw new BadRequestException('Invalid request.');
        const account = await this.accounts.findOne({ where: { id: req.userId } });
        if (!account) throw new UnauthorizedException('Account not found.');
        const lesson = await this.lessons.findOne({ where: { id: body.lessonId } });
        if (!lesson) throw new NotFoundException('Lesson not found.');
        if (!lesson.hashedAnswer) {
            throw new BadRequestException("This lesson isn't graded yet — try again after the admin runs the hash sync.");
        }

        const result = await this.validator.executeShader(VERTEX_SHADER, body.fragmentShader, VERIFICATION_TIME);
        if (!result.ok) {
            if (result.compileError) throw new BadRequestException('Shader compile error.');
            this.log.warn(`Validator error for lesson ${lesson.id}: ${result.error}`);
            throw new BadGatewayException('Validator unavailable.');
        }

        const correct = equalsConstantTime(result.imageHash, lesson.hashedAnswer);
        const attempt = this.attempts.create({
            status: correct ? 'SUCCESSFUL' : 'FAILED',
            account, lesson,
        });
        await this.attempts.save(attempt);
        if (!correct) throw new BadRequestException('Incorrect.');
        return 'Correct.';
    }

    /**
     * Admin-only batch endpoint. Renders every lesson's canonical shader through the validator
     * and stores the resulting imageHash. Idempotent.
     */
    @Post('recompute-hashes')
    @UseGuards(AdminGuard)
    @HttpCode(200)
    async recomputeHashes(): Promise<any> {
        const updated: any[] = [];
        const skipped: any[] = [];
        const failed: any[]  = [];

        const all = await this.lessons.find();
        for (const lesson of all) {
            const body = lesson.canonicalFragmentShader;
            if (!body || body.trim().length === 0) {
                skipped.push({ id: lesson.id, title: lesson.title, reason: 'no canonical shader' });
                continue;
            }
            const result = await this.validator.executeShader(
                VERTEX_SHADER, FRAGMENT_HEADER + body, VERIFICATION_TIME,
            );
            if (!result.ok) {
                failed.push({ id: lesson.id, title: lesson.title, error: result.error });
                continue;
            }
            lesson.hashedAnswer = result.imageHash;
            await this.lessons.save(lesson);
            updated.push({ id: lesson.id, title: lesson.title, hash: result.imageHash });
        }

        return { updated, skipped, failed, verificationTime: VERIFICATION_TIME };
    }

    @Post()
    @UseGuards(AdminGuard)
    @HttpCode(201)
    async create(@Body() body: CreateLessonBody): Promise<LessonDto> {
        if (!body?.courseId || !body?.slug || !body?.title) throw new BadRequestException();
        const course = await this.courses.findOne({ where: { id: body.courseId } });
        if (!course) throw new NotFoundException();
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

    @Put(':id')
    @UseGuards(AdminGuard)
    async update(@Param('id') id: string, @Body() body: Partial<UpdateLessonBody>): Promise<LessonDto> {
        const l = await this.lessons.findOne({ where: { id } });
        if (!l) throw new NotFoundException();
        if (body.slug != null) l.slug = body.slug;
        if (body.displayOrder != null) l.displayOrder = body.displayOrder;
        if (body.title != null) l.title = body.title;
        if (body.description != null) l.description = body.description;
        if (body.starterVertexShader != null) l.starterVertexShader = body.starterVertexShader;
        if (body.starterFragmentShader != null) l.starterFragmentShader = body.starterFragmentShader;
        if (body.canonicalFragmentShader != null) l.canonicalFragmentShader = body.canonicalFragmentShader;
        if (body.hashedAnswer != null) l.hashedAnswer = body.hashedAnswer;
        return toDto(await this.lessons.save(l));
    }

    @Delete(':id')
    @UseGuards(AdminGuard)
    @HttpCode(204)
    async remove(@Param('id') id: string): Promise<void> {
        const l = await this.lessons.findOne({ where: { id } });
        if (!l) throw new NotFoundException();
        await this.lessons.remove(l);
    }
}
