import {
    BeforeInsert, Column, CreateDateColumn, Entity, JoinColumn, ManyToOne,
    PrimaryGeneratedColumn,
} from 'typeorm';
import { randomUUID } from 'crypto';

/**
 * init.sql declares `id VARCHAR(36) PRIMARY KEY` with NO database-side default.
 * TypeORM's @PrimaryGeneratedColumn('uuid') only generates the UUID client-side
 * for some driver/column combinations; with VARCHAR(36) and synchronize:false,
 * Postgres receives `id = null` and rejects (23502).
 *
 * Filling it in via @BeforeInsert is the portable workaround.
 */
function ensureId(entity: { id?: string }) {
    if (!entity.id) entity.id = randomUUID();
}

@Entity('account')
export class Account {
    @PrimaryGeneratedColumn('uuid') id: string;
    @Column({ unique: true }) username: string;
    @Column() password: string;
    @Column({ nullable: true }) email?: string;
    @Column({ nullable: true }) country?: string;
    @Column({ nullable: true }) bio?: string;
    @CreateDateColumn({ name: 'created_at' }) createdAt: Date;

    @BeforeInsert() _id() { ensureId(this); }
}

export type Difficulty = 'beginner' | 'intermediate' | 'advanced';

@Entity('course')
export class Course {
    @PrimaryGeneratedColumn('uuid') id: string;
    @Column({ unique: true }) slug: string;
    @Column() title: string;
    @Column({ type: 'text', nullable: true }) description?: string;
    @Column({ default: 'Fundamentals' }) category: string;
    @Column({ default: 'beginner' }) difficulty: Difficulty;
    @Column({ name: 'display_order', default: 0 }) displayOrder: number;
    @CreateDateColumn({ name: 'created_at' }) createdAt: Date;

    @BeforeInsert() _id() { ensureId(this); }
}

@Entity('lesson')
export class Lesson {
    @PrimaryGeneratedColumn('uuid') id: string;

    @ManyToOne(() => Course, { eager: true })
    @JoinColumn({ name: 'course_id' })
    course: Course;

    @Column() slug: string;
    @Column({ name: 'display_order', default: 0 }) displayOrder: number;
    @Column() title: string;
    @Column({ type: 'text', nullable: true }) description?: string;

    @Column({ name: 'starter_vertex_shader', type: 'text', nullable: true })
    starterVertexShader?: string;

    @Column({ name: 'starter_fragment_shader', type: 'text', nullable: true })
    starterFragmentShader?: string;

    @Column({ name: 'canonical_fragment_shader', type: 'text', nullable: true })
    canonicalFragmentShader?: string;

    /** Optional plain-text guidance injected into the Concierge AI's system prompt for this lesson only. */
    @Column({ name: 'concierge_hint', type: 'text', nullable: true })
    conciergeHint?: string;

    @Column({ name: 'hashed_answer', nullable: true })
    hashedAnswer?: string;

    @CreateDateColumn({ name: 'created_at' }) createdAt: Date;

    @BeforeInsert() _id() { ensureId(this); }
}

@Entity('comment')
export class Comment {
    @PrimaryGeneratedColumn('uuid') id: string;
    @Column({ type: 'text', nullable: true }) code?: string;
    @Column({ length: 512, nullable: true }) content?: string;

    @ManyToOne(() => Account, { eager: true, nullable: true, onDelete: 'SET NULL' })
    @JoinColumn({ name: 'account' })
    account?: Account;

    @ManyToOne(() => Lesson, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'lesson' })
    lesson: Lesson;

    @CreateDateColumn({ name: 'created_at' }) createdAt: Date;

    @BeforeInsert() _id() { ensureId(this); }
}

export type AttemptStatus = 'SUCCESSFUL' | 'FAILED' | 'UNATTEMPTED';

@Entity('attempt')
export class Attempt {
    @PrimaryGeneratedColumn('uuid') id: string;
    @Column() status: AttemptStatus;

    @ManyToOne(() => Account, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'account' })
    account: Account;

    @ManyToOne(() => Lesson, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'lesson' })
    lesson: Lesson;

    @CreateDateColumn({ name: 'created_at' }) createdAt: Date;

    @BeforeInsert() _id() { ensureId(this); }
}
