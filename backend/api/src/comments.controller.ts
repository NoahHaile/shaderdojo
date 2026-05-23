import {
    Controller, Delete, Get, HttpCode, Param, UseGuards,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Comment } from './entities';
import { AdminGuard } from './admin.guard';

class CommentResponseDto {
    id: string; code: string | null; content: string | null; username: string | null;
}

@Controller('comments')
export class CommentsController {
    constructor(@InjectRepository(Comment) private readonly comments: Repository<Comment>) {}

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
            username: c.account?.username ?? null,
        }));
    }

    @Delete(':id')
    @UseGuards(AdminGuard)
    @HttpCode(204)
    async remove(@Param('id') id: string): Promise<void> {
        await this.comments.delete(id);
    }
}
