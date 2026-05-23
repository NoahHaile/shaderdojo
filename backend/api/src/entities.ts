import {
    Column, CreateDateColumn, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn,
} from 'typeorm';

@Entity('account')
export class Account {
    @PrimaryGeneratedColumn('uuid') id: string;
    @Column({ unique: true }) username: string;
    @Column() password: string;
    @Column({ nullable: true }) email?: string;
    @Column({ nullable: true }) country?: string;
    @Column({ nullable: true }) bio?: string;
    @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
}

@Entity('course')
export class Course {
    @PrimaryGeneratedColumn('uuid') id: string;
    @Column({ unique: true }) slug: string;
    @Column() title: string;
    @Column({ type: 'text', nullable: true }) description?: string;
    @Column({ name: 'display_order', default: 0 }) displayOrder: number;
    @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
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

    @Column({ name: 'hashed_answer', nullable: true })
    hashedAnswer?: string;

    @CreateDateColumn({ name: 'created_at' }) createdAt: Date;
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
}
