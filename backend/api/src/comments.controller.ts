import {
    BadRequestException, Body, Controller, Delete, Get, HttpCode, NotFoundException,
    Param, Post, Req, UseGuards,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Account, Comment, Lesson } from './entities';
import { AdminGuard } from './admin.guard';
import { OptionalJwt } from './optional-jwt';

class CommentResponseDto {
    id: string; code: string | null; content: string | null; username: string | null;
}

class CreateCommentBody { code?: string; content?: string; }

@Controller('comments')
export class CommentsController {
    constructor(
        @InjectRepository(Comment) private readonly comments: Repository<Comment>,
        @InjectRepository(Lesson)  private readonly lessons:  Repository<Lesson>,
        @InjectRepository(Account) private readonly accounts: Repository<Account>,
        private readonly optJwt: OptionalJwt,
    ) {}

    /** Public: list comments for a lesson. */
    @Get(':lessonId')
    async list(@Param('lessonId') lessonId: string): Promise<CommentResponseDto[]> {
        const rows = await this.comments.find({
            where: { lesson: { id: lessonId } },
            order: { id: 'DESC' },
        });
        return rows.map(c => ({
            id: c.id,
            code: c.code ?? null,
            content: c.content ?? null,
            username: c.account?.username ?? null,    // null → frontend renders "Anonymous"
        }));
    }

    /**
     * Optional-auth: anyone can comment. Signed-in users get attribution;
     * anonymous comments save with account = null and render as Anonymous.
     */
    @Post(':lessonId')
    @HttpCode(201)
    async create(
        @Param('lessonId') lessonId: string,
        @Body() body: CreateCommentBody,
        @Req() req: any,
    ): Promise<CommentResponseDto> {
        const trimmedCode    = (body?.code ?? '').trim();
        const trimmedContent = (body?.content ?? '').trim();
        if (!trimmedCode && !trimmedContent) {
            throw new BadRequestException('Comment must include code or content.');
        }
        const lesson = await this.lessons.findOne({ where: { id: lessonId } });
        if (!lesson) throw new NotFoundException();

        let account: Account | null = null;
        const userId = await this.optJwt.userIdFrom(req);
        if (userId) {
            account = await this.accounts.findOne({ where: { id: userId } });
        }

        const c = this.comments.create({
            code: trimmedCode || null,
            content: trimmedContent || null,
            account: account ?? undefined,
            lesson,
        });
        const saved = await this.comments.save(c);
        return {
            id: saved.id,
            code: saved.code ?? null,
            content: saved.content ?? null,
            username: account?.username ?? null,
        };
    }

    /** Admin: hard delete a comment. */
    @Delete(':id')
    @UseGuards(AdminGuard)
    @HttpCode(204)
    async remove(@Param('id') id: string): Promise<void> {
        await this.comments.delete(id);
    }
}
