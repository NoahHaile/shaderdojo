import {
    BadRequestException, Body, Controller, Delete, Get, HttpCode, NotFoundException,
    Param, Post, Put, UseGuards,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Course, Lesson } from './entities';
import { AdminGuard } from './admin.guard';

class CourseDto {
    id: string; slug: string; title: string; description: string | null; displayOrder: number;
}
class LessonSummaryDto {
    id: string; slug: string; title: string; displayOrder: number; verified: boolean;
}
class CourseDetailDto extends CourseDto { lessons: LessonSummaryDto[]; }
class CreateCourseBody { slug: string; title: string; description?: string; displayOrder?: number; }

function toSummary(l: Lesson): LessonSummaryDto {
    return {
        id: l.id, slug: l.slug, title: l.title,
        displayOrder: l.displayOrder, verified: !!l.hashedAnswer,
    };
}

@Controller('courses')
export class CoursesController {
    constructor(
        @InjectRepository(Course) private readonly courses: Repository<Course>,
        @InjectRepository(Lesson) private readonly lessons: Repository<Lesson>,
    ) {}

    /** GET /courses → all courses, each with nested lesson summaries. */
    @Get()
    async list(): Promise<CourseDetailDto[]> {
        const cs = await this.courses.find({ order: { displayOrder: 'ASC', title: 'ASC' } });
        const out: CourseDetailDto[] = [];
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
    @Get(':slug')
    async detail(@Param('slug') slug: string): Promise<CourseDetailDto> {
        const c = await this.courses.findOne({ where: { slug } });
        if (!c) throw new NotFoundException();
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

    @Post()
    @UseGuards(AdminGuard)
    @HttpCode(201)
    async create(@Body() body: CreateCourseBody): Promise<CourseDto> {
        if (!body?.slug || !body?.title) throw new BadRequestException();
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

    @Put(':id')
    @UseGuards(AdminGuard)
    async update(@Param('id') id: string, @Body() body: Partial<CreateCourseBody>): Promise<CourseDto> {
        const c = await this.courses.findOne({ where: { id } });
        if (!c) throw new NotFoundException();
        if (body.slug != null) c.slug = body.slug;
        if (body.title != null) c.title = body.title;
        if (body.description != null) c.description = body.description;
        if (body.displayOrder != null) c.displayOrder = body.displayOrder;
        const saved = await this.courses.save(c);
        return {
            id: saved.id, slug: saved.slug, title: saved.title,
            description: saved.description ?? null, displayOrder: saved.displayOrder,
        };
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
