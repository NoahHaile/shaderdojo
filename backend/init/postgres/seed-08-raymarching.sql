\c shader_dojo;

-- Family G — Raymarching (9 courses, 36 lessons)

INSERT INTO lesson (id, course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: ray-pinhole-camera =====
('c0000025-0001-0000-0000-000000000000', 'c0000025-0000-0000-0000-000000000000', 'bVzyIUm-AXM', 0,
 'Ray direction colormap',
 '<p>Raymarching starts with a camera. For every pixel, build a ray with an origin <code>ro</code> and a normalized direction <code>rd</code>. Visualize the direction itself by mapping it into <code>[0, 1]</code> with <code>0.5 + 0.5 * rd</code>.</p><p>The classic pinhole setup: ray origin sits on the +Z axis looking down -Z, and the screen UV (aspect-corrected) becomes the xy of the ray, with a negative z to point forward.</p><p>Reference: <a href="https://iquilezles.org/articles/raymarchingdf/" target="_blank" rel="noreferrer">IQ — Raymarching SDFs</a>.</p>',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    // TODO: output 0.5 + 0.5 * rd as the color.
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
}',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    gl_FragColor = vec4(0.5 + 0.5 * rd, 1.0);
}'),

('c0000025-0002-0000-0000-000000000000', 'c0000025-0000-0000-0000-000000000000', 'PEQw3x0crzo', 1,
 'Move camera origin',
 '<p>The camera origin is just a point in 3D space. Shift it to <code>vec3(0.5, 0.2, 3.0)</code> — slightly to the right and up — and watch the ray-direction colormap shift accordingly.</p><p>The directions still come from the same screen UV, but the camera "lives" somewhere new in the world.</p><p>Reference: <a href="https://iquilezles.org/articles/raytracing/" target="_blank" rel="noreferrer">IQ — Oldschool raytracing</a>.</p>',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    // TODO: set ro = vec3(0.5, 0.2, 3.0).
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    gl_FragColor = vec4(0.5 + 0.5 * rd, 1.0);
}',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.5, 0.2, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    gl_FragColor = vec4(0.5 + 0.5 * rd, 1.0);
}'),

('c0000025-0003-0000-0000-000000000000', 'c0000025-0000-0000-0000-000000000000', 'TQm4GRgYoEI', 2,
 'Camera lookat',
 '<p>A lookat camera aims at a target point <code>ta</code>. Build an orthonormal basis: forward <code>f = normalize(ta - ro)</code>, right <code>r = normalize(cross(f, world_up))</code>, and up <code>u = cross(r, f)</code>. The ray direction is then <code>r*uv.x + u*uv.y + f*focal</code>, normalized.</p><p>This decouples the camera position from where it points.</p><p>Reference: <a href="https://iquilezles.org/articles/raytracing/" target="_blank" rel="noreferrer">IQ — Oldschool raytracing</a>.</p>',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    // TODO: build a lookat basis aimed at vec3(0) and compute rd from it (focal = 1.5).
    vec3 rd = normalize(vec3(uv, -1.5));
    gl_FragColor = vec4(0.5 + 0.5 * rd, 1.0);
}',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 ta = vec3(0.0);
    vec3 f = normalize(ta - ro);
    vec3 r = normalize(cross(f, vec3(0.0, 1.0, 0.0)));
    vec3 u = cross(r, f);
    vec3 rd = normalize(r * uv.x + u * uv.y + f * 1.5);
    gl_FragColor = vec4(0.5 + 0.5 * rd, 1.0);
}'),

('c0000025-0004-0000-0000-000000000000', 'c0000025-0000-0000-0000-000000000000', '9x9McVR69e4', 3,
 'FOV scaling',
 '<p>The focal length sets the field of view. Replace the hardcoded <code>-1.5</code> with a FOV-driven form: <code>rd = normalize(vec3(uv * tan(fov/2), -1.0))</code>. A larger angle gives a wider lens.</p><p>Here <code>fov = 1.0</code> radian (~57°), so <code>tan(0.5)</code> scales the screen UV.</p><p>Reference: <a href="https://iquilezles.org/articles/raytracing/" target="_blank" rel="noreferrer">IQ — Oldschool raytracing</a>.</p>',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    // TODO: rd = normalize(vec3(uv * tan(0.5), -1.0));
    vec3 rd = normalize(vec3(uv, -1.5));
    gl_FragColor = vec4(0.5 + 0.5 * rd, 1.0);
}',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv * tan(0.5), -1.0));
    gl_FragColor = vec4(0.5 + 0.5 * rd, 1.0);
}'),

-- ===== Course: sdf-3d-primitives =====
('c0000026-0001-0000-0000-000000000000', 'c0000026-0000-0000-0000-000000000000', '0K7XuOgb6Ug', 0,
 'Sphere',
 '<p>A signed distance function returns how far the closest surface is, negative inside. The sphere SDF is the canonical example: <code>length(p) - r</code>.</p><p>Visualize it on a 2D slice: set <code>p = vec3(uv, 0.0)</code> and shade by <code>1.0 - smoothstep(0.0, 0.05, d)</code> — black outside, white inside, with an antialiased edge.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions/" target="_blank" rel="noreferrer">IQ — 3D SDFs</a>.</p>',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 p = vec3(uv, 0.0);
    // TODO: d = length(p) - 0.5;
    float d = 1.0;
    float m = 1.0 - smoothstep(0.0, 0.05, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 p = vec3(uv, 0.0);
    float d = length(p) - 0.5;
    float m = 1.0 - smoothstep(0.0, 0.05, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

('c0000026-0002-0000-0000-000000000000', 'c0000026-0000-0000-0000-000000000000', 'j2k8NNueePM', 1,
 'Box',
 '<p>The box SDF uses a clever trick: take <code>q = abs(p) - halfSize</code>, then the distance is <code>length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0)</code>. The first term handles points outside, the second handles points inside.</p><p>Visualize the same way as the sphere: 2D slice, smoothstep on the distance.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions/" target="_blank" rel="noreferrer">IQ — 3D SDFs</a>.</p>',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 p = vec3(uv, 0.0);
    // TODO: q = abs(p) - vec3(0.4, 0.3, 0.3); d = length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
    float d = 1.0;
    float m = 1.0 - smoothstep(0.0, 0.05, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 p = vec3(uv, 0.0);
    vec3 q = abs(p) - vec3(0.4, 0.3, 0.3);
    float d = length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
    float m = 1.0 - smoothstep(0.0, 0.05, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

('c0000026-0003-0000-0000-000000000000', 'c0000026-0000-0000-0000-000000000000', 'zhMoauT9MJQ', 2,
 'Ground plane',
 '<p>A horizontal plane is the simplest SDF of all: <code>p.y - h</code> for the plane <code>y = h</code>. Negative below, positive above.</p><p>Slice it at <code>z = 0</code> and you see a half-space split along a horizontal line at <code>y = -0.4</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions/" target="_blank" rel="noreferrer">IQ — 3D SDFs</a>.</p>',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 p = vec3(uv, 0.0);
    // TODO: d = p.y + 0.4;
    float d = 1.0;
    float m = 1.0 - smoothstep(0.0, 0.05, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 p = vec3(uv, 0.0);
    float d = p.y + 0.4;
    float m = 1.0 - smoothstep(0.0, 0.05, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

('c0000026-0004-0000-0000-000000000000', 'c0000026-0000-0000-0000-000000000000', 'yfswq5aK_l8', 3,
 'Torus',
 '<p>A torus is a circle of circles. Form a 2D coordinate <code>q = vec2(length(p.xz) - R, p.y)</code> — the distance to the major ring on the xz plane and the height — then <code>length(q) - r</code> is the distance to the tube.</p><p>Reference: <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf</a>.</p>',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 p = vec3(uv, 0.0);
    // TODO: q = vec2(length(p.xz) - 0.4, p.y); d = length(q) - 0.15;
    float d = 1.0;
    float m = 1.0 - smoothstep(0.0, 0.05, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 p = vec3(uv, 0.0);
    vec2 q = vec2(length(p.xz) - 0.4, p.y);
    float d = length(q) - 0.15;
    float m = 1.0 - smoothstep(0.0, 0.05, d);
    gl_FragColor = vec4(vec3(m), 1.0);
}'),

-- ===== Course: sphere-tracing =====
('c0000027-0001-0000-0000-000000000000', 'c0000027-0000-0000-0000-000000000000', 'xu3F6SH4e5c', 0,
 'A 64-step march',
 '<p>Sphere tracing walks along a ray in steps equal to the SDF value — the largest step guaranteed not to overshoot any surface. Loop up to 64 times, advance <code>t</code> by <code>scene(ro + t*rd)</code>, and stop when the distance drops below a small epsilon or <code>t</code> grows too large.</p><p>Output white on hit, black on miss.</p><p>Reference: <a href="https://iquilezles.org/articles/raymarchingdf/" target="_blank" rel="noreferrer">IQ — Raymarching SDFs</a>.</p>',
 'float scene(vec3 p) { return length(p) - 0.6; }
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    // TODO: loop 64 times, advance t by scene(ro + t*rd), set hit = true when d < 0.001, break when t > 10.0.
    gl_FragColor = vec4(vec3(hit ? 1.0 : 0.0), 1.0);
}',
 'float scene(vec3 p) { return length(p) - 0.6; }
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    gl_FragColor = vec4(vec3(hit ? 1.0 : 0.0), 1.0);
}'),

('c0000027-0002-0000-0000-000000000000', 'c0000027-0000-0000-0000-000000000000', 'u4Qn8Ib_h_Q', 1,
 'Sky fallback',
 '<p>Black skies are harsh. Replace the miss color with a soft blue: <code>vec3(0.7, 0.85, 1.0)</code>. The hit color stays white so the sphere reads as a clear silhouette against the sky.</p><p>Reference: <a href="https://iquilezles.org/articles/nvscene2008/" target="_blank" rel="noreferrer">IQ — NVScene 2008 talk</a>.</p>',
 'float scene(vec3 p) { return length(p) - 0.6; }
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    // TODO: col = hit ? vec3(1.0) : vec3(0.7, 0.85, 1.0);
    vec3 col = vec3(hit ? 1.0 : 0.0);
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return length(p) - 0.6; }
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = hit ? vec3(1.0) : vec3(0.7, 0.85, 1.0);
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000027-0003-0000-0000-000000000000', 'c0000027-0000-0000-0000-000000000000', 'Xvj_ruSggEU', 2,
 'Hit distance gray',
 '<p>The hit distance <code>t</code> tells you how far each surface pixel is from the camera. Use it as a grayscale shading — closer surfaces brighter, farther surfaces darker — to get a rough depth pass.</p><p>Output <code>vec3(1.0 - t * 0.2)</code> on hit, sky on miss.</p><p>Reference: <a href="https://iquilezles.org/articles/raymarchingdf/" target="_blank" rel="noreferrer">IQ — Raymarching SDFs</a>.</p>',
 'float scene(vec3 p) { return length(p) - 0.6; }
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    // TODO: col = hit ? vec3(1.0 - t * 0.2) : vec3(0.7, 0.85, 1.0);
    vec3 col = vec3(0.7, 0.85, 1.0);
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return length(p) - 0.6; }
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = hit ? vec3(1.0 - t * 0.2) : vec3(0.7, 0.85, 1.0);
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000027-0004-0000-0000-000000000000', 'c0000027-0000-0000-0000-000000000000', 'u0dEXd6T_aQ', 3,
 'Per-step visualization',
 '<p>The number of march iterations is a great diagnostic — silhouettes and glancing rays cost many steps, normal hits cost few. Track an int <code>iters</code> inside the loop and output <code>vec3(iters / 64.0)</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/nvscene2008/" target="_blank" rel="noreferrer">IQ — NVScene 2008 talk</a>.</p>',
 'float scene(vec3 p) { return length(p) - 0.6; }
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    int iters = 0;
    // TODO: march 64 times, increment iters each step, break on hit (d<0.001) or t>10.0.
    gl_FragColor = vec4(vec3(float(iters) / 64.0), 1.0);
}',
 'float scene(vec3 p) { return length(p) - 0.6; }
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    int iters = 0;
    for (int i = 0; i < 64; i++) {
        iters = i + 1;
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) break;
        if (t > 10.0) break;
        t += d;
    }
    gl_FragColor = vec4(vec3(float(iters) / 64.0), 1.0);
}'),

-- ===== Course: surface-normals =====
('c0000028-0001-0000-0000-000000000000', 'c0000028-0000-0000-0000-000000000000', 'hVfifCrsTSc', 0,
 'Central-difference normal',
 '<p>The gradient of an SDF is the surface normal. Approximate it with six taps at <code>±epsilon</code> along each axis and normalize — the classic central-difference trick.</p><p>Visualize as <code>0.5 + 0.5 * n</code>: a sphere shows the rainbow of axis-aligned colors that gives this technique away.</p><p>Reference: <a href="https://iquilezles.org/articles/normalsSDF/" target="_blank" rel="noreferrer">IQ — Normals for SDFs</a>.</p>',
 'float scene(vec3 p) { return length(p) - 0.6; }
vec3 normal(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0.0, 0.0)) - scene(p - vec3(e, 0.0, 0.0)),
        scene(p + vec3(0.0, e, 0.0)) - scene(p - vec3(0.0, e, 0.0)),
        scene(p + vec3(0.0, 0.0, e)) - scene(p - vec3(0.0, 0.0, e))
    ));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    // TODO: col = hit ? 0.5 + 0.5 * normal(p) : vec3(0.7, 0.85, 1.0);
    vec3 col = vec3(0.7, 0.85, 1.0);
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return length(p) - 0.6; }
vec3 normal(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0.0, 0.0)) - scene(p - vec3(e, 0.0, 0.0)),
        scene(p + vec3(0.0, e, 0.0)) - scene(p - vec3(0.0, e, 0.0)),
        scene(p + vec3(0.0, 0.0, e)) - scene(p - vec3(0.0, 0.0, e))
    ));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = hit ? 0.5 + 0.5 * normal(p) : vec3(0.7, 0.85, 1.0);
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000028-0002-0000-0000-000000000000', 'c0000028-0000-0000-0000-000000000000', '6tNC-7kiS8I', 1,
 'Normal as RGB on a torus',
 '<p>Swap the sphere for a torus and the rainbow becomes a wrapping band — the normals point outward along the tube and run through every direction as the surface curves.</p><p>This is the standard "normal debug" view that ray-marchers use to confirm geometry is correct before adding lighting.</p><p>Reference: <a href="https://iquilezles.org/articles/normalsSDF/" target="_blank" rel="noreferrer">IQ — Normals for SDFs</a>.</p>',
 'float scene(vec3 p) {
    vec2 q = vec2(length(p.xz) - 0.5, p.y);
    return length(q) - 0.18;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0.0, 0.0)) - scene(p - vec3(e, 0.0, 0.0)),
        scene(p + vec3(0.0, e, 0.0)) - scene(p - vec3(0.0, e, 0.0)),
        scene(p + vec3(0.0, 0.0, e)) - scene(p - vec3(0.0, 0.0, e))
    ));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    // TODO: col = hit ? 0.5 + 0.5 * normal(p) : vec3(0.7, 0.85, 1.0);
    vec3 col = vec3(0.7, 0.85, 1.0);
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) {
    vec2 q = vec2(length(p.xz) - 0.5, p.y);
    return length(q) - 0.18;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0.0, 0.0)) - scene(p - vec3(e, 0.0, 0.0)),
        scene(p + vec3(0.0, e, 0.0)) - scene(p - vec3(0.0, e, 0.0)),
        scene(p + vec3(0.0, 0.0, e)) - scene(p - vec3(0.0, 0.0, e))
    ));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = hit ? 0.5 + 0.5 * normal(p) : vec3(0.7, 0.85, 1.0);
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000028-0003-0000-0000-000000000000', 'c0000028-0000-0000-0000-000000000000', 'hU4e94qsXZc', 2,
 'Tetrahedron normals',
 '<p>The 6-tap central difference is accurate but expensive. A 4-tap variant places samples at the corners of a tetrahedron — same quality, two fewer scene evaluations. The four offsets are <code>(1,-1,-1), (-1,-1,1), (-1,1,-1), (1,1,1)</code>, scaled by epsilon.</p><p>Result looks the same as the 6-tap on a sphere, but it''s cheaper per pixel.</p><p>Reference: <a href="https://iquilezles.org/articles/normalsSDF/" target="_blank" rel="noreferrer">IQ — Normals for SDFs</a>.</p>',
 'float scene(vec3 p) { return length(p) - 0.6; }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    // TODO: return normalize(k0*scene(p+k0*e) + k1*scene(p+k1*e) + k2*scene(p+k2*e) + k3*scene(p+k3*e));
    return vec3(0.0, 1.0, 0.0);
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = hit ? 0.5 + 0.5 * normal(p) : vec3(0.7, 0.85, 1.0);
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return length(p) - 0.6; }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = hit ? 0.5 + 0.5 * normal(p) : vec3(0.7, 0.85, 1.0);
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000028-0004-0000-0000-000000000000', 'c0000028-0000-0000-0000-000000000000', 'P2oCPl_JxcA', 3,
 'Tetrahedron normals on a torus',
 '<p>Combine the 4-tap normal with the torus SDF. Same cheap normal trick, more interesting geometry. This is the form you''ll reuse for the rest of the family — efficient normals are the default in modern raymarching pipelines.</p><p>Reference: <a href="https://iquilezles.org/articles/normalsSDF/" target="_blank" rel="noreferrer">IQ — Normals for SDFs</a>.</p>',
 'float scene(vec3 p) {
    vec2 q = vec2(length(p.xz) - 0.5, p.y);
    return length(q) - 0.18;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    // TODO: return normalize(k0*scene(p+k0*e) + k1*scene(p+k1*e) + k2*scene(p+k2*e) + k3*scene(p+k3*e));
    return vec3(0.0, 1.0, 0.0);
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = hit ? 0.5 + 0.5 * normal(p) : vec3(0.7, 0.85, 1.0);
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) {
    vec2 q = vec2(length(p.xz) - 0.5, p.y);
    return length(q) - 0.18;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = hit ? 0.5 + 0.5 * normal(p) : vec3(0.7, 0.85, 1.0);
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: diffuse-lighting =====
('c0000029-0001-0000-0000-000000000000', 'c0000029-0000-0000-0000-000000000000', 'FsZLd2lCBdI', 0,
 'Lambertian dot',
 '<p>Lambert''s law: the diffuse brightness of a surface is <code>max(dot(n, l), 0.0)</code>, where <code>n</code> is the surface normal and <code>l</code> is the direction toward the light. Negative dot products mean the surface faces away, so we clamp to zero.</p><p>Output the raw scalar on all three channels to see the grayscale shading.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
 'float scene(vec3 p) { return length(p) - 0.6; }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        // TODO: diff = max(dot(n, l), 0.0); col = vec3(diff);
        col = vec3(0.0);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return length(p) - 0.6; }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(diff);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000029-0002-0000-0000-000000000000', 'c0000029-0000-0000-0000-000000000000', '7UuAMgw9ykc', 1,
 'Directional sun',
 '<p>Tint the diffuse term with a warm sun color: <code>vec3(1.0, 0.95, 0.8) * diff</code>. The shape stays the same but the lit side now reads as sunlight instead of neutral gray.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
 'float scene(vec3 p) { return length(p) - 0.6; }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        // TODO: col = vec3(1.0, 0.95, 0.8) * diff;
        col = vec3(diff);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return length(p) - 0.6; }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(1.0, 0.95, 0.8) * diff;
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000029-0003-0000-0000-000000000000', 'c0000029-0000-0000-0000-000000000000', 'LTRI21yWBS8', 2,
 'Ambient floor',
 '<p>Pure diffuse leaves shadowed surfaces pitch black. Add a small ambient term — a constant color that fills in the dark side. A cool blue ambient against a warm sun makes the lighting feel outdoors.</p><p>Mix: <code>vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
 'float scene(vec3 p) { return length(p) - 0.6; }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        // TODO: col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
        col = vec3(1.0, 0.95, 0.8) * diff;
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return length(p) - 0.6; }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000029-0004-0000-0000-000000000000', 'c0000029-0000-0000-0000-000000000000', 'w3Qvls85ClU', 3,
 'Two-light setup',
 '<p>Real scenes have more than one light. Use a warm key and a cool fill from opposite-ish directions: <code>diff1 * warm + diff2 * cool</code>. The result reads as a sun-and-sky combo without needing image-based lighting.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
 'float scene(vec3 p) { return length(p) - 0.6; }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l1 = normalize(vec3(0.5, 0.8, 0.3));
        vec3 l2 = normalize(vec3(-0.5, 0.4, 0.7));
        // TODO: diff1 = max(dot(n,l1),0.0); diff2 = max(dot(n,l2),0.0); col = diff1*vec3(1.0,0.95,0.8) + diff2*vec3(0.3,0.5,0.9);
        col = vec3(0.0);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return length(p) - 0.6; }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l1 = normalize(vec3(0.5, 0.8, 0.3));
        vec3 l2 = normalize(vec3(-0.5, 0.4, 0.7));
        float diff1 = max(dot(n, l1), 0.0);
        float diff2 = max(dot(n, l2), 0.0);
        col = diff1 * vec3(1.0, 0.95, 0.8) + diff2 * vec3(0.3, 0.5, 0.9);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: soft-shadows =====
('c0000030-0001-0000-0000-000000000000', 'c0000030-0000-0000-0000-000000000000', 'Z7KFdyL36U0', 0,
 'Hard step shadow',
 '<p>A hard shadow is just a second raymarch from the hit point toward the light. If anything blocks the ray before it escapes, the point is in shadow.</p><p>Offset the start by <code>0.01 * n</code> to avoid self-intersection. Return 0 if blocked, 1 if clear, and multiply with the diffuse term.</p><p>Reference: <a href="https://iquilezles.org/articles/rmshadows/" target="_blank" rel="noreferrer">IQ — Raymarched soft shadows</a>.</p>',
 'float scene(vec3 p) { return min(length(p - vec3(0.0, 0.1, 0.0)) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
float hardShadow(vec3 ro, vec3 rd) {
    float t = 0.02;
    for (int i = 0; i < 32; i++) {
        float d = scene(ro + t * rd);
        if (d < 0.001) return 0.0;
        t += d;
        if (t > 6.0) break;
    }
    return 1.0;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        // TODO: sh = hardShadow(p + 0.01*n, l); col = vec3(diff * sh);
        col = vec3(diff);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return min(length(p - vec3(0.0, 0.1, 0.0)) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
float hardShadow(vec3 ro, vec3 rd) {
    float t = 0.02;
    for (int i = 0; i < 32; i++) {
        float d = scene(ro + t * rd);
        if (d < 0.001) return 0.0;
        t += d;
        if (t > 6.0) break;
    }
    return 1.0;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        float sh = hardShadow(p + 0.01 * n, l);
        col = vec3(diff * sh);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000030-0002-0000-0000-000000000000', 'c0000030-0000-0000-0000-000000000000', 'yckztV5ltTY', 1,
 'Soft accumulation',
 '<p>For a soft shadow, don''t return 0 on first contact — track the minimum of <code>k*d/t</code> over the whole march. Points that pass close to a surface (small <code>d</code>) but never quite hit produce a partial occlusion.</p><p>The constant <code>k</code> controls softness: smaller = blurrier penumbra.</p><p>Reference: <a href="https://iquilezles.org/articles/rmshadows/" target="_blank" rel="noreferrer">IQ — Raymarched soft shadows</a>.</p>',
 'float scene(vec3 p) { return min(length(p - vec3(0.0, 0.1, 0.0)) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
float softShadow(vec3 ro, vec3 rd, float k) {
    float res = 1.0;
    float t = 0.02;
    for (int i = 0; i < 32; i++) {
        float d = scene(ro + t * rd);
        if (d < 0.001) return 0.0;
        res = min(res, k * d / t);
        t += d;
        if (t > 6.0) break;
    }
    return res;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        // TODO: sh = softShadow(p + 0.01*n, l, 8.0); col = vec3(diff * sh);
        col = vec3(diff);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return min(length(p - vec3(0.0, 0.1, 0.0)) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
float softShadow(vec3 ro, vec3 rd, float k) {
    float res = 1.0;
    float t = 0.02;
    for (int i = 0; i < 32; i++) {
        float d = scene(ro + t * rd);
        if (d < 0.001) return 0.0;
        res = min(res, k * d / t);
        t += d;
        if (t > 6.0) break;
    }
    return res;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        float sh = softShadow(p + 0.01 * n, l, 8.0);
        col = vec3(diff * sh);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000030-0003-0000-0000-000000000000', 'c0000030-0000-0000-0000-000000000000', 'qJsdfh4K0aw', 2,
 'Tuning k',
 '<p>Raise <code>k</code> to <code>16.0</code> and the penumbra tightens — shadow edges read sharper, more like a physical area light that''s closer to the surface. Lower <code>k</code> values give the broad soft-shadow look of a distant light.</p><p>Reference: <a href="https://iquilezles.org/articles/sphereshadow/" target="_blank" rel="noreferrer">IQ — Sphere shadow</a>.</p>',
 'float scene(vec3 p) { return min(length(p - vec3(0.0, 0.1, 0.0)) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
float softShadow(vec3 ro, vec3 rd, float k) {
    float res = 1.0;
    float t = 0.02;
    for (int i = 0; i < 32; i++) {
        float d = scene(ro + t * rd);
        if (d < 0.001) return 0.0;
        res = min(res, k * d / t);
        t += d;
        if (t > 6.0) break;
    }
    return res;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        // TODO: sh = softShadow(p + 0.01*n, l, 16.0); col = vec3(diff * sh);
        col = vec3(diff);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return min(length(p - vec3(0.0, 0.1, 0.0)) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
float softShadow(vec3 ro, vec3 rd, float k) {
    float res = 1.0;
    float t = 0.02;
    for (int i = 0; i < 32; i++) {
        float d = scene(ro + t * rd);
        if (d < 0.001) return 0.0;
        res = min(res, k * d / t);
        t += d;
        if (t > 6.0) break;
    }
    return res;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        float sh = softShadow(p + 0.01 * n, l, 16.0);
        col = vec3(diff * sh);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000030-0004-0000-0000-000000000000', 'c0000030-0000-0000-0000-000000000000', 'nNC62N_E5dY', 3,
 'Sphere on ground with full lighting',
 '<p>Put it all together: a sphere sitting on a ground plane, warm sun + cool ambient, soft shadow modulating only the direct light (the ambient should not be shadowed — that''s why it''s ambient).</p><p>This is the canonical "raymarched sphere" shot you''ll see across thousands of Shadertoy entries.</p><p>Reference: <a href="https://iquilezles.org/articles/rmshadows/" target="_blank" rel="noreferrer">IQ — Raymarched soft shadows</a>.</p>',
 'float scene(vec3 p) { return min(length(p - vec3(0.0, 0.1, 0.0)) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
float softShadow(vec3 ro, vec3 rd, float k) {
    float res = 1.0;
    float t = 0.02;
    for (int i = 0; i < 32; i++) {
        float d = scene(ro + t * rd);
        if (d < 0.001) return 0.0;
        res = min(res, k * d / t);
        t += d;
        if (t > 6.0) break;
    }
    return res;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        // TODO: sh = softShadow(p + 0.01*n, l, 8.0); col = vec3(0.2,0.25,0.35)*0.4 + vec3(1.0,0.95,0.8) * diff * sh;
        col = vec3(diff);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return min(length(p - vec3(0.0, 0.1, 0.0)) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
float softShadow(vec3 ro, vec3 rd, float k) {
    float res = 1.0;
    float t = 0.02;
    for (int i = 0; i < 32; i++) {
        float d = scene(ro + t * rd);
        if (d < 0.001) return 0.0;
        res = min(res, k * d / t);
        t += d;
        if (t > 6.0) break;
    }
    return res;
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        float sh = softShadow(p + 0.01 * n, l, 8.0);
        col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff * sh;
    }
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: sdf-3d-ops =====
('c0000031-0001-0000-0000-000000000000', 'c0000031-0000-0000-0000-000000000000', 'TLG-cK9XTpM', 0,
 'Union, intersect, subtract',
 '<p>The three boolean ops on SDFs are simple: <code>min(a, b)</code> for union, <code>max(a, b)</code> for intersection, <code>max(a, -b)</code> for subtraction. They produce the expected solid-modeling shapes.</p><p>Carve a smaller sphere out of a larger one with subtract — the dent should be clearly visible on the side.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions/" target="_blank" rel="noreferrer">IQ — 3D SDFs (boolean ops)</a>.</p>',
 'float sphere(vec3 p, vec3 c, float r) { return length(p - c) - r; }
float scene(vec3 p) {
    float a = sphere(p, vec3(0.0), 0.5);
    float b = sphere(p, vec3(0.3, 0.0, 0.0), 0.4);
    // TODO: return max(a, -b); (subtract b from a)
    return a;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float sphere(vec3 p, vec3 c, float r) { return length(p - c) - r; }
float scene(vec3 p) {
    float a = sphere(p, vec3(0.0), 0.5);
    float b = sphere(p, vec3(0.3, 0.0, 0.0), 0.4);
    return max(a, -b);
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000031-0002-0000-0000-000000000000', 'c0000031-0000-0000-0000-000000000000', '8-aKpiS-z9M', 1,
 'Infinite repetition',
 '<p>Apply <code>mod()</code> on the position before evaluating the SDF and the geometry repeats forever. Centre the repetition cell by shifting half-period: <code>p.xz = mod(p.xz + 0.5, 1.0) - 0.5</code>.</p><p>One sphere becomes a regular lattice of spheres — for free.</p><p>Reference: <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ — SDF domain repetition</a>.</p>',
 'float scene(vec3 p) {
    // TODO: p.xz = mod(p.xz + 0.5, 1.0) - 0.5;
    return length(p) - 0.3;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) {
    p.xz = mod(p.xz + 0.5, 1.0) - 0.5;
    return length(p) - 0.3;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000031-0003-0000-0000-000000000000', 'c0000031-0000-0000-0000-000000000000', '5c7nPSy_T_M', 2,
 'Finite repetition',
 '<p>Infinite repetition is wasteful when only a few copies are needed. Clamp the cell index to limit the range: <code>p.x -= 0.5 * clamp(floor(p.x/0.5 + 0.5), -2.0, 2.0)</code> produces five copies along x, then stops.</p><p>Reference: <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ — SDF domain repetition</a>.</p>',
 'float scene(vec3 p) {
    // TODO: p.x = p.x - 0.5 * clamp(floor(p.x/0.5 + 0.5), -2.0, 2.0);
    return length(p) - 0.2;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) {
    p.x = p.x - 0.5 * clamp(floor(p.x / 0.5 + 0.5), -2.0, 2.0);
    return length(p) - 0.2;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000031-0004-0000-0000-000000000000', 'c0000031-0000-0000-0000-000000000000', 'zc-V-hMIrr8', 3,
 'Axis fold',
 '<p>Mirror the world across an axis by taking the absolute value: <code>p.x = abs(p.x)</code>. Place a single sphere on the positive side and you get two — fold across two axes and you get four.</p><p>This is the cheapest way to add symmetry to a scene.</p><p>Reference: <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf (mirror operators)</a>.</p>',
 'float scene(vec3 p) {
    // TODO: p.x = abs(p.x); p.z = abs(p.z); return length(p - vec3(0.3, 0.0, 0.3)) - 0.25;
    return length(p) - 0.5;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) {
    p.x = abs(p.x);
    p.z = abs(p.z);
    return length(p - vec3(0.3, 0.0, 0.3)) - 0.25;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
    }
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: sdf-fbm-detail =====
('c0000032-0001-0000-0000-000000000000', 'c0000032-0000-0000-0000-000000000000', 'AMPKI9l6IaI', 0,
 'Sphere plus fbm bumps',
 '<p>Subtracting an fbm field from a sphere SDF perturbs the surface — small <code>AMP</code> values stay roughly distance-correct, large ones blow up. Start with <code>AMP = 0.05</code> for subtle, well-behaved bumps.</p><p>Reference: <a href="https://iquilezles.org/articles/fbmsdf/" target="_blank" rel="noreferrer">IQ — fbm detail in SDFs</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float a = 0.5, s = 0.0;
    for (int i = 0; i < 4; i++) { s += a * vnoise(p); p *= 2.0; a *= 0.5; }
    return s;
}
float scene(vec3 p) {
    float bump = fbm(p.xy * 4.0 + p.z * 4.0) * 0.05;
    // TODO: return length(p) - 0.5 - bump;
    return length(p) - 0.5;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(diff);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float a = 0.5, s = 0.0;
    for (int i = 0; i < 4; i++) { s += a * vnoise(p); p *= 2.0; a *= 0.5; }
    return s;
}
float scene(vec3 p) {
    float bump = fbm(p.xy * 4.0 + p.z * 4.0) * 0.05;
    return length(p) - 0.5 - bump;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(diff);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000032-0002-0000-0000-000000000000', 'c0000032-0000-0000-0000-000000000000', 'h9wc7eeaHkM', 1,
 'Larger amplitude',
 '<p>Push <code>AMP</code> to <code>0.12</code> and the lumps become craggy. The sphere tracer can still find the surface, but each step travels less ground because the SDF is no longer a tight distance bound — many shaders multiply the bumpy SDF by <code>0.5</code> to compensate. We''ll keep that detail for a later lesson.</p><p>Reference: <a href="https://iquilezles.org/articles/fbmsdf/" target="_blank" rel="noreferrer">IQ — fbm detail in SDFs</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float a = 0.5, s = 0.0;
    for (int i = 0; i < 4; i++) { s += a * vnoise(p); p *= 2.0; a *= 0.5; }
    return s;
}
float scene(vec3 p) {
    // TODO: bump = fbm(p.xy*4.0 + p.z*4.0) * 0.12; return length(p) - 0.5 - bump;
    float bump = fbm(p.xy * 4.0 + p.z * 4.0) * 0.05;
    return length(p) - 0.5 - bump;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(diff);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float a = 0.5, s = 0.0;
    for (int i = 0; i < 4; i++) { s += a * vnoise(p); p *= 2.0; a *= 0.5; }
    return s;
}
float scene(vec3 p) {
    float bump = fbm(p.xy * 4.0 + p.z * 4.0) * 0.12;
    return length(p) - 0.5 - bump;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(diff);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000032-0003-0000-0000-000000000000', 'c0000032-0000-0000-0000-000000000000', 'CL7nsnsDvAM', 2,
 'Higher frequency',
 '<p>Double the fbm input frequency from <code>4.0</code> to <code>8.0</code> and the bumps become smaller and more numerous. The amplitude stays at <code>0.05</code> so the SDF behaviour remains good.</p><p>This is how you dial detail size without losing surface stability.</p><p>Reference: <a href="https://iquilezles.org/articles/fbm/" target="_blank" rel="noreferrer">IQ — fbm</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float a = 0.5, s = 0.0;
    for (int i = 0; i < 4; i++) { s += a * vnoise(p); p *= 2.0; a *= 0.5; }
    return s;
}
float scene(vec3 p) {
    // TODO: bump = fbm(p.xy*8.0 + p.z*8.0) * 0.05; return length(p) - 0.5 - bump;
    float bump = fbm(p.xy * 4.0 + p.z * 4.0) * 0.05;
    return length(p) - 0.5 - bump;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(diff);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float a = 0.5, s = 0.0;
    for (int i = 0; i < 4; i++) { s += a * vnoise(p); p *= 2.0; a *= 0.5; }
    return s;
}
float scene(vec3 p) {
    float bump = fbm(p.xy * 8.0 + p.z * 8.0) * 0.05;
    return length(p) - 0.5 - bump;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(diff);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000032-0004-0000-0000-000000000000', 'c0000032-0000-0000-0000-000000000000', 'Xoz_PpTzWmY', 3,
 'Combine bumps with lighting',
 '<p>The bumpy sphere shading gets dramatic when you add proper lighting: warm directional + cool ambient + computed normals. The normal estimator picks up the fbm detail automatically because it samples the scene SDF.</p><p>Reference: <a href="https://iquilezles.org/articles/fbmsdf/" target="_blank" rel="noreferrer">IQ — fbm detail in SDFs</a>.</p>',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float a = 0.5, s = 0.0;
    for (int i = 0; i < 4; i++) { s += a * vnoise(p); p *= 2.0; a *= 0.5; }
    return s;
}
float scene(vec3 p) {
    float bump = fbm(p.xy * 4.0 + p.z * 4.0) * 0.05;
    return length(p) - 0.5 - bump;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        // TODO: col = vec3(0.2,0.25,0.35)*0.4 + vec3(1.0,0.95,0.8) * diff;
        col = vec3(diff);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float a = 0.5, s = 0.0;
    for (int i = 0; i < 4; i++) { s += a * vnoise(p); p *= 2.0; a *= 0.5; }
    return s;
}
float scene(vec3 p) {
    float bump = fbm(p.xy * 4.0 + p.z * 4.0) * 0.05;
    return length(p) - 0.5 - bump;
}
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
    }
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: fog-and-ao =====
('c0000033-0001-0000-0000-000000000000', 'c0000033-0000-0000-0000-000000000000', 'j67c2TrN84Q', 0,
 'Linear depth fog',
 '<p>Fog blends the surface color with a sky color based on distance. The simplest form is a linear ramp: <code>mix(color, sky, clamp(t / maxDist, 0, 1))</code>.</p><p>Far surfaces lose contrast and approach the sky color — instant depth cue.</p><p>Reference: <a href="https://iquilezles.org/articles/fog/" target="_blank" rel="noreferrer">IQ — Better fog</a>.</p>',
 'float scene(vec3 p) { return min(length(p) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 sky = vec3(0.7, 0.85, 1.0);
    vec3 col = sky;
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
        // TODO: col = mix(col, sky, clamp(t / 8.0, 0.0, 1.0));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return min(length(p) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 sky = vec3(0.7, 0.85, 1.0);
    vec3 col = sky;
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
        col = mix(col, sky, clamp(t / 8.0, 0.0, 1.0));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000033-0002-0000-0000-000000000000', 'c0000033-0000-0000-0000-000000000000', 'wagyMhq2jqA', 1,
 'Exponential fog',
 '<p>Physical fog falls off exponentially: <code>factor = 1.0 - exp(-t * density)</code>. With <code>density = 0.3</code>, near surfaces are nearly untouched and far ones blend smoothly into the sky.</p><p>Reference: <a href="https://iquilezles.org/articles/fog/" target="_blank" rel="noreferrer">IQ — Better fog</a>.</p>',
 'float scene(vec3 p) { return min(length(p) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 sky = vec3(0.7, 0.85, 1.0);
    vec3 col = sky;
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
        // TODO: factor = 1.0 - exp(-t * 0.3); col = mix(col, sky, factor);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return min(length(p) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 sky = vec3(0.7, 0.85, 1.0);
    vec3 col = sky;
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
        float factor = 1.0 - exp(-t * 0.3);
        col = mix(col, sky, factor);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000033-0003-0000-0000-000000000000', 'c0000033-0000-0000-0000-000000000000', 'J2xhJR_1Hq4', 2,
 'Five-tap ambient occlusion',
 '<p>Ambient occlusion approximates how much of the surrounding scene blocks ambient light. Sample the SDF a few times along the normal, weighted with a falloff: gaps between expected and actual distance indicate occluders.</p><p>The 5-tap formula <code>ao -= (h - scene(p + h*n)) * pow(0.7, i)</code> is the classic IQ short version.</p><p>Reference: <a href="https://iquilezles.org/articles/multiresaocc/" target="_blank" rel="noreferrer">IQ — Multiresolution ambient occlusion</a>.</p>',
 'float scene(vec3 p) { return min(length(p) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
float ao(vec3 pos, vec3 n) {
    float a = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = scene(pos + h * n);
        a -= (h - d) * pow(0.7, float(i));
    }
    return clamp(a, 0.0, 1.0);
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        // TODO: a = ao(p, n); col = vec3(a);
        col = vec3(1.0);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return min(length(p) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
float ao(vec3 pos, vec3 n) {
    float a = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = scene(pos + h * n);
        a -= (h - d) * pow(0.7, float(i));
    }
    return clamp(a, 0.0, 1.0);
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 n = normal(p);
        float a = ao(p, n);
        col = vec3(a);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

('c0000033-0004-0000-0000-000000000000', 'c0000033-0000-0000-0000-000000000000', 'Ud1X-GP_RQQ', 3,
 'AO and fog combined',
 '<p>The full small-scene recipe: diffuse * AO + ambient, then exponential fog over the result. AO darkens crevices, fog flattens distance, and the lighting gives the surface its shape. This is the building block for the bigger ray-marched scenes that follow this family.</p><p>Reference: <a href="https://iquilezles.org/articles/sphereao/" target="_blank" rel="noreferrer">IQ — Sphere ambient occlusion</a>.</p>',
 'float scene(vec3 p) { return min(length(p) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
float ao(vec3 pos, vec3 n) {
    float a = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = scene(pos + h * n);
        a -= (h - d) * pow(0.7, float(i));
    }
    return clamp(a, 0.0, 1.0);
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 sky = vec3(0.7, 0.85, 1.0);
    vec3 col = sky;
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        float a = ao(p, n);
        // TODO: col = vec3(1.0,0.95,0.8) * diff * a + vec3(0.2,0.25,0.35) * 0.4; col = mix(col, sky, 1.0 - exp(-t*0.3));
        col = vec3(diff);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'float scene(vec3 p) { return min(length(p) - 0.5, p.y + 0.3); }
vec3 normal(vec3 p) {
    float e = 0.001;
    vec3 k0 = vec3( 1.0, -1.0, -1.0);
    vec3 k1 = vec3(-1.0, -1.0,  1.0);
    vec3 k2 = vec3(-1.0,  1.0, -1.0);
    vec3 k3 = vec3( 1.0,  1.0,  1.0);
    return normalize(k0 * scene(p + k0 * e) + k1 * scene(p + k1 * e) + k2 * scene(p + k2 * e) + k3 * scene(p + k3 * e));
}
float ao(vec3 pos, vec3 n) {
    float a = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = scene(pos + h * n);
        a -= (h - d) * pow(0.7, float(i));
    }
    return clamp(a, 0.0, 1.0);
}
void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));
    float t = 0.0;
    bool hit = false;
    vec3 p;
    for (int i = 0; i < 64; i++) {
        p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 sky = vec3(0.7, 0.85, 1.0);
    vec3 col = sky;
    if (hit) {
        vec3 n = normal(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        float a = ao(p, n);
        col = vec3(1.0, 0.95, 0.8) * diff * a + vec3(0.2, 0.25, 0.35) * 0.4;
        col = mix(col, sky, 1.0 - exp(-t * 0.3));
    }
    gl_FragColor = vec4(col, 1.0);
}');
