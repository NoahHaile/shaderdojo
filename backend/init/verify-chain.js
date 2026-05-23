// Reads init.sql, extracts each lesson's (course_id, display_order, starter, canonical),
// and verifies lesson N+1.starter == lesson N.canonical (byte-equal) within each course.
// Run: node backend/init/verify-chain.js

const fs = require('fs');
const path = require('path');

const sql = fs.readFileSync(path.join(__dirname, 'postgres', 'init.sql'), 'utf8');

// Parser state: walk the file, find each `INSERT INTO lesson`, then find the
// following `VALUES (` and walk forward tracking paren depth, treating
// single-quoted strings (with '' as an escape) as opaque.
function extractLessonValueBlocks(src) {
    const blocks = [];
    let i = 0;
    while (true) {
        const idx = src.indexOf('INSERT INTO lesson', i);
        if (idx === -1) break;
        const valuesIdx = src.indexOf('VALUES (', idx);
        if (valuesIdx === -1) break;
        let p = valuesIdx + 'VALUES ('.length;
        let depth = 1;
        let inStr = false;
        let start = p;
        while (p < src.length && depth > 0) {
            const ch = src[p];
            if (inStr) {
                if (ch === "'" && src[p + 1] === "'") { p += 2; continue; }
                if (ch === "'") { inStr = false; p++; continue; }
                p++;
                continue;
            }
            if (ch === "'") { inStr = true; p++; continue; }
            if (ch === '(') { depth++; p++; continue; }
            if (ch === ')') {
                depth--;
                if (depth === 0) {
                    blocks.push(src.slice(start, p));
                    p++;
                    break;
                }
                p++;
                continue;
            }
            p++;
        }
        i = p;
    }
    return blocks;
}

// Splits the comma-separated VALUES interior into typed parts, honoring '' escapes.
function splitValues(values) {
    const out = [];
    let i = 0;
    while (i < values.length) {
        while (i < values.length && /[\s,]/.test(values[i])) i++;
        if (i >= values.length) break;
        if (values[i] === "'") {
            let s = '';
            i++;
            while (i < values.length) {
                if (values[i] === "'") {
                    if (values[i + 1] === "'") { s += "'"; i += 2; continue; }
                    i++;
                    break;
                }
                s += values[i];
                i++;
            }
            out.push({ type: 'str', val: s });
        } else {
            let n = '';
            while (i < values.length && values[i] !== ',') { n += values[i]; i++; }
            out.push({ type: 'raw', val: n.trim() });
        }
    }
    return out;
}

const blocks = extractLessonValueBlocks(sql);
const lessons = [];
for (const block of blocks) {
    const parts = splitValues(block);
    // (id, course_id, slug, display_order, title, description,
    //  starter_vertex_shader, starter_fragment_shader, canonical_fragment_shader)
    if (parts.length < 9) continue;
    lessons.push({
        id: parts[0].val,
        courseId: parts[1].val,
        slug: parts[2].val,
        displayOrder: parseInt(parts[3].val, 10),
        title: parts[4].val,
        starter: parts[7].val,
        canonical: parts[8].val,
    });
}

const byCourse = new Map();
for (const l of lessons) {
    if (!byCourse.has(l.courseId)) byCourse.set(l.courseId, []);
    byCourse.get(l.courseId).push(l);
}

let problems = 0;
const summary = [];
for (const [courseId, list] of byCourse) {
    list.sort((a, b) => a.displayOrder - b.displayOrder);
    summary.push(`Course ${courseId}: ${list.length} lessons (${list.map(l => l.slug).join(', ')})`);
    for (let i = 1; i < list.length; i++) {
        const prev = list[i - 1];
        const cur = list[i];
        if (prev.canonical !== cur.starter) {
            problems++;
            console.log(`\n[MISMATCH] course=${courseId} ${prev.slug}.canonical != ${cur.slug}.starter`);
            console.log('--- prev.canonical ---');
            console.log(prev.canonical);
            console.log('--- cur.starter ---');
            console.log(cur.starter);
        }
    }
}

console.log('\n' + summary.join('\n'));
console.log(`\nTotal lessons: ${lessons.length}`);
console.log(problems === 0 ? 'Chain OK: every N+1 starter equals N canonical.' : `Chain FAIL: ${problems} mismatches.`);
process.exit(problems === 0 ? 0 : 1);
