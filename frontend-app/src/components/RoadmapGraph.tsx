// Home-page roadmap rendered as a dependency graph.
//
// Nodes = courses, edges = prerequisites (see ../courseDependencies.ts).
// Dagre lays out top-to-bottom; the user can pan and zoom inside the canvas.
// Clicking a node navigates to /courses?slug=<slug>. Completion progress is
// pulled from the same useCompletedLessons hook the rest of the app uses.

import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    Background, BackgroundVariant, Controls, Handle, MiniMap, Position, ReactFlow,
    type Edge, type Node, type NodeProps,
} from '@xyflow/react';
import dagre from '@dagrejs/dagre';
import '@xyflow/react/dist/style.css';
import { coursesApi, type Course, type Difficulty } from '../api';
import { useCompletedLessons } from '../completion';
import { COURSE_PREREQUISITES } from '../courseDependencies';

const NODE_WIDTH = 220;
const NODE_HEIGHT = 92;

interface CourseNodeData extends Record<string, unknown> {
    course: Course;
    done: number;
    total: number;
}
type CourseNode = Node<CourseNodeData, 'course'>;

const DIFFICULTY_COLOR: Record<Difficulty, string> = {
    beginner:     '#86efac', // green-300
    intermediate: '#fcd34d', // amber-300
    advanced:     '#fca5a5', // red-300
};

function layout(nodes: CourseNode[], edges: Edge[]): { nodes: CourseNode[]; edges: Edge[] } {
    const g = new dagre.graphlib.Graph();
    g.setGraph({ rankdir: 'TB', nodesep: 36, ranksep: 64, marginx: 24, marginy: 24 });
    g.setDefaultEdgeLabel(() => ({}));

    for (const n of nodes) g.setNode(n.id, { width: NODE_WIDTH, height: NODE_HEIGHT });
    for (const e of edges) g.setEdge(e.source, e.target);

    dagre.layout(g);

    return {
        nodes: nodes.map((n) => {
            const pos = g.node(n.id);
            return {
                ...n,
                position: { x: pos.x - NODE_WIDTH / 2, y: pos.y - NODE_HEIGHT / 2 },
                sourcePosition: Position.Bottom,
                targetPosition: Position.Top,
            };
        }),
        edges,
    };
}

function CourseNodeView({ data }: NodeProps<CourseNode>) {
    const { course, done, total } = data;
    const allDone = total > 0 && done === total;
    const started = done > 0;
    const pct = total > 0 ? (done / total) * 100 : 0;

    return (
        <div
            className={
                'rounded-lg border bg-cream shadow-sm px-3 py-2 transition cursor-pointer ' +
                'hover:shadow-md hover:-translate-y-0.5 ' +
                (allDone
                    ? 'border-accent'
                    : started
                        ? 'border-primary'
                        : 'border-muted/40')
            }
            style={{ width: NODE_WIDTH, height: NODE_HEIGHT }}
        >
            <Handle type="target" position={Position.Top} className="!bg-muted/40 !w-2 !h-2" />
            <div className="flex items-start justify-between gap-2">
                <h4 className="font-sans text-sm font-semibold text-ink leading-tight line-clamp-2">
                    {course.title}
                </h4>
                <span
                    className="mt-0.5 w-2 h-2 rounded-full shrink-0"
                    style={{ background: DIFFICULTY_COLOR[course.difficulty] }}
                    title={course.difficulty}
                    aria-label={`difficulty: ${course.difficulty}`}
                />
            </div>
            <div className="mt-1.5 flex items-center gap-1.5 text-[11px] text-muted">
                <span>{course.category}</span>
                {course.underReview && (
                    <span className="text-[9px] uppercase tracking-wide text-ink/40">· under review</span>
                )}
            </div>
            <div className="mt-1.5 flex items-center gap-2">
                <div className="flex-1 h-1 rounded-full bg-muted/20 overflow-hidden">
                    <div
                        className={'h-full transition-all ' + (allDone ? 'bg-accent' : 'bg-primary')}
                        style={{ width: `${pct}%` }}
                    />
                </div>
                <span className="font-mono text-[10px] text-muted tabular-nums shrink-0">
                    {allDone ? '✓' : `${done}/${total}`}
                </span>
            </div>
            <Handle type="source" position={Position.Bottom} className="!bg-muted/40 !w-2 !h-2" />
        </div>
    );
}

const NODE_TYPES = { course: CourseNodeView } as const;

export function RoadmapGraph() {
    const [courses, setCourses] = useState<Course[] | null>(null);
    const [error, setError] = useState<string | null>(null);
    const completed = useCompletedLessons();
    const navigate = useNavigate();

    useEffect(() => {
        coursesApi.list()
            .then(setCourses)
            .catch((e: any) => setError(e?.message ?? 'Failed to load roadmap'));
    }, []);

    const { nodes, edges } = useMemo(() => {
        if (!courses) return { nodes: [] as CourseNode[], edges: [] as Edge[] };

        const bySlug = new Map(courses.map((c) => [c.slug, c]));
        const rawNodes: CourseNode[] = courses.map((course) => {
            const total = course.lessons.length;
            const done = course.lessons.reduce(
                (n, l) => n + (completed.has(l.id) ? 1 : 0), 0);
            return {
                id: course.slug,
                type: 'course',
                position: { x: 0, y: 0 },
                data: { course, done, total },
            };
        });

        const rawEdges: Edge[] = [];
        for (const [slug, prereqs] of Object.entries(COURSE_PREREQUISITES)) {
            if (!bySlug.has(slug)) continue;
            for (const prereq of prereqs) {
                if (!bySlug.has(prereq)) continue;
                rawEdges.push({
                    id: `${prereq}->${slug}`,
                    source: prereq,
                    target: slug,
                    style: { stroke: '#cbd0d4', strokeWidth: 1.2 },
                });
            }
        }

        return layout(rawNodes, rawEdges);
    }, [courses, completed]);

    if (error) return <p className="text-sm text-red-600">{error}</p>;
    if (!courses) return <RoadmapSkeleton />;

    return (
        <div className="relative w-full" style={{ height: '70vh', minHeight: 480 }}>
            <ReactFlow
                nodes={nodes}
                edges={edges}
                nodeTypes={NODE_TYPES}
                onNodeClick={(_e, n) => navigate(`/courses?slug=${encodeURIComponent(n.id)}`)}
                fitView
                fitViewOptions={{ padding: 0.15 }}
                proOptions={{ hideAttribution: true }}
                nodesDraggable={false}
                nodesConnectable={false}
                edgesFocusable={false}
                minZoom={0.3}
                maxZoom={1.5}
            >
                <Background variant={BackgroundVariant.Dots} gap={20} size={1} color="#e5e7eb" />
                <Controls showInteractive={false} className="!shadow-sm" />
                <MiniMap
                    pannable
                    zoomable
                    maskColor="rgba(250, 250, 250, 0.6)"
                    nodeColor={(n) => {
                        const d = (n.data as CourseNodeData | undefined);
                        if (!d) return '#fafafa';
                        if (d.total > 0 && d.done === d.total) return '#fe7e7e';
                        if (d.done > 0) return '#ffff83';
                        return '#fafafa';
                    }}
                    nodeStrokeColor="#AAA"
                />
            </ReactFlow>
        </div>
    );
}

function RoadmapSkeleton() {
    return (
        <div className="w-full bg-cream/40 rounded-lg" style={{ height: '70vh', minHeight: 480 }}>
            <div className="h-full grid place-items-center text-sm text-muted">
                Loading roadmap…
            </div>
        </div>
    );
}
