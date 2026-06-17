import {
    BadRequestException, Body, Controller, Delete, Get, HttpCode, NotFoundException,
    Param, Post, Put, UseGuards,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Course, Difficulty, Lesson } from './entities';
import { AdminGuard } from './admin.guard';

class CourseDto {
    id: string; slug: string; title: string; description: string | null;
    category: string; difficulty: Difficulty; displayOrder: number; underReview: boolean;
}
class LessonSummaryDto {
    id: string; slug: string; title: string; displayOrder: number; verified: boolean;
}
class CourseDetailDto extends CourseDto { lessons: LessonSummaryDto[]; }

class CreateCourseBody {
    slug: string; title: string;
    description?: string;
    category?: string;
    difficulty?: Difficulty;
    displayOrder?: number;
    underReview?: boolean;
}

const VALID_DIFFICULTY: ReadonlySet<Difficulty> = new Set(['beginner', 'intermediate', 'advanced']);

function toSummary(l: Lesson): LessonSummaryDto {
    return {
        id: l.id, slug: l.slug, title: l.title,
        displayOrder: l.displayOrder, verified: !!l.hashedAnswer,
    };
}

function toCourseDto(c: Course): CourseDto {
    return {
        id: c.id, slug: c.slug, title: c.title,
        description: c.description ?? null,
        category: c.category, difficulty: c.difficulty,
        displayOrder: c.displayOrder, underReview: c.underReview,
    };
}

@Controller('courses')
export class CoursesController {
    constructor(
        @InjectRepository(Course) private readonly courses: Repository<Course>,
        @InjectRepository(Lesson) private readonly lessons: Repository<Lesson>,
    ) {}

    /** GET /courses → all courses (with category/difficulty), each with nested lesson summaries. */
    @Get()
    async list(): Promise<CourseDetailDto[]> {
        const cs = await this.courses.find({
            order: { category: 'ASC', displayOrder: 'ASC', title: 'ASC' },
        });
        const out: CourseDetailDto[] = [];
        for (const c of cs) {
            const lessons = await this.lessons.find({
                where: { course: { id: c.id } },
                order: { displayOrder: 'ASC', title: 'ASC' },
            });
            out.push({ ...toCourseDto(c), lessons: lessons.map(toSummary) });
        }
        return out;
    }

    @Get(':slug')
    async detail(@Param('slug') slug: string): Promise<CourseDetailDto> {
        const c = await this.courses.findOne({ where: { slug } });
        if (!c) throw new NotFoundException();
        const lessons = await this.lessons.find({
            where: { course: { id: c.id } },
            order: { displayOrder: 'ASC', title: 'ASC' },
        });
        return { ...toCourseDto(c), lessons: lessons.map(toSummary) };
    }

    @Post()
    @UseGuards(AdminGuard)
    @HttpCode(201)
    async create(@Body() body: CreateCourseBody): Promise<CourseDto> {
        if (!body?.slug || !body?.title) throw new BadRequestException();
        if (body.difficulty && !VALID_DIFFICULTY.has(body.difficulty)) {
            throw new BadRequestException('difficulty must be beginner | intermediate | advanced');
        }
        const c = this.courses.create({
            slug: body.slug, title: body.title,
            description: body.description ?? null,
            category: body.category ?? 'Fundamentals',
            difficulty: body.difficulty ?? 'beginner',
            displayOrder: body.displayOrder ?? 0,
            underReview: body.underReview ?? false,
        });
        return toCourseDto(await this.courses.save(c));
    }

    @Put(':id')
    @UseGuards(AdminGuard)
    async update(@Param('id') id: string, @Body() body: Partial<CreateCourseBody>): Promise<CourseDto> {
        const c = await this.courses.findOne({ where: { id } });
        if (!c) throw new NotFoundException();
        if (body.difficulty && !VALID_DIFFICULTY.has(body.difficulty)) {
            throw new BadRequestException('difficulty must be beginner | intermediate | advanced');
        }
        if (body.slug != null)         c.slug = body.slug;
        if (body.title != null)        c.title = body.title;
        if (body.description != null)  c.description = body.description;
        if (body.category != null)     c.category = body.category;
        if (body.difficulty != null)   c.difficulty = body.difficulty;
        if (body.displayOrder != null) c.displayOrder = body.displayOrder;
        if (body.underReview != null)  c.underReview = body.underReview;
        return toCourseDto(await this.courses.save(c));
    }

    @Delete(':id')
    @UseGuards(AdminGuard)
    @HttpCode(204)
    async remove(@Param('id') id: string): Promise<void> {
        const c = await this.courses.findOne({ where: { id } });
        if (!c) throw new NotFoundException();
        await this.courses.remove(c);
    }
}
