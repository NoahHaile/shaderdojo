\c shader_dojo;

-- Family G — Raymarching (9 courses, 36 lessons)

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: ray-pinhole-camera =====
((SELECT id FROM course WHERE slug = 'ray-pinhole-camera'), 'bVzyIUm-AXM', 0,
 'Ray direction colormap',
 '<p>Raymarching needs a camera. For each pixel, build a ray. A ray is a 3D line with a start point <code>ro</code> and a direction <code>rd</code>. The direction must be a unit vector.</p><p>You can see the direction as a color. Use <code>0.5 + 0.5 * rd</code> to map it to <code>[0, 1]</code>. Put the camera at <code>(0, 0, 3)</code> looking down -Z. The screen UV becomes the ray''s x and y. The z is negative so the ray points forward.</p><p>Reference: <a href="https://iquilezles.org/articles/raymarchingdf/" target="_blank" rel="noreferrer">IQ — Raymarching SDFs</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'ray-pinhole-camera'), 'PEQw3x0crzo', 1,
 'Move camera origin',
 '<p>The camera start <code>ro</code> is just a 3D point. You can move it. Try <code>vec3(0.5, 0.2, 3.0)</code>. That shifts the camera right and up.</p><p>The colors will shift too. The directions still come from the same screen UV. But the camera now sits in a new spot.</p><p>Reference: <a href="https://iquilezles.org/articles/raytracing/" target="_blank" rel="noreferrer">IQ — Oldschool raytracing</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'ray-pinhole-camera'), 'TQm4GRgYoEI', 2,
 'Camera lookat',
 '<p>A lookat camera aims at a target point <code>ta</code>. You build three axes from <code>ro</code> and <code>ta</code>. Forward is <code>f = normalize(ta - ro)</code>. Right is <code>r = normalize(cross(f, world_up))</code>. Up is <code>u = cross(r, f)</code>.</p><p>The ray direction is <code>r*uv.x + u*uv.y + f*focal</code>, normalized. Now you can move the camera and the aim apart.</p><p>Reference: <a href="https://iquilezles.org/articles/raytracing/" target="_blank" rel="noreferrer">IQ — Oldschool raytracing</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'ray-pinhole-camera'), '9x9McVR69e4', 3,
 'FOV scaling',
 '<p>The focal length sets the field of view. Field of view is how wide the lens sees. Swap the fixed <code>-1.5</code> for an angle-based form. Use <code>rd = normalize(vec3(uv * tan(fov/2), -1.0))</code>.</p><p>A bigger angle means a wider lens. Here <code>fov = 1.0</code> radian (about 57 degrees). So <code>tan(0.5)</code> scales the screen UV.</p><p>Reference: <a href="https://iquilezles.org/articles/raytracing/" target="_blank" rel="noreferrer">IQ — Oldschool raytracing</a>.</p>',
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
((SELECT id FROM course WHERE slug = 'sdf-3d-primitives'), '0K7XuOgb6Ug', 0,
 'Sphere',
 '<p>A 3D SDF gives a number for any point. Negative inside the shape. Positive outside. Zero on the surface. The sphere SDF is <code>length(p) - r</code>.</p><p>You can see it on a flat 2D slice. Set <code>p = vec3(uv, 0.0)</code>. Shade with <code>1.0 - smoothstep(0.0, 0.05, d)</code>. That gives white inside, black outside, and a smooth edge.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions/" target="_blank" rel="noreferrer">IQ — 3D SDFs</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'sdf-3d-primitives'), 'j2k8NNueePM', 1,
 'Box',
 '<p>The box SDF has two parts. First take <code>q = abs(p) - halfSize</code>. Then the distance is <code>length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0)</code>.</p><p>The first term works for points outside the box. The second works for points inside. View it the same way as the sphere. Use a 2D slice and smoothstep on the distance.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions/" target="_blank" rel="noreferrer">IQ — 3D SDFs</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'sdf-3d-primitives'), 'zhMoauT9MJQ', 2,
 'Ground plane',
 '<p>A flat ground plane is the simplest SDF. For the plane <code>y = h</code>, the SDF is <code>p.y - h</code>. It is negative below the plane and positive above.</p><p>Slice it at <code>z = 0</code>. You see the space split along a horizontal line at <code>y = -0.4</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions/" target="_blank" rel="noreferrer">IQ — 3D SDFs</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'sdf-3d-primitives'), 'yfswq5aK_l8', 3,
 'Torus',
 '<p>A torus is a donut shape. It is a circle of circles. Build a 2D point <code>q = vec2(length(p.xz) - R, p.y)</code>. The x part is the distance to the big ring on the xz plane. The y part is the height.</p><p>Then <code>length(q) - r</code> is the distance to the tube. <code>R</code> is the ring size and <code>r</code> is the tube size.</p><p>Reference: <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf</a>.</p>',
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
((SELECT id FROM course WHERE slug = 'sphere-tracing'), 'xu3F6SH4e5c', 0,
 'A 64-step march',
 '<p>Sphere tracing walks along the ray. At each step, you jump forward by the SDF value. That is the biggest safe jump. It will not pass through a surface.</p><p>Loop up to 64 times. Add <code>scene(ro + t*rd)</code> to <code>t</code> each step. Stop when the distance drops below a small number (you hit). Or stop when <code>t</code> gets too big (you missed). Output white on hit, black on miss.</p><p>Reference: <a href="https://iquilezles.org/articles/raymarchingdf/" target="_blank" rel="noreferrer">IQ — Raymarching SDFs</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'sphere-tracing'), 'u4Qn8Ib_h_Q', 1,
 'Sky fallback',
 '<p>A black sky looks harsh. Swap it for a soft blue. Use <code>vec3(0.7, 0.85, 1.0)</code> on miss.</p><p>The hit color stays white. Now the sphere stands out against the sky.</p><p>Reference: <a href="https://iquilezles.org/articles/nvscene2008/" target="_blank" rel="noreferrer">IQ — NVScene 2008 talk</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'sphere-tracing'), 'Xvj_ruSggEU', 2,
 'Hit distance gray',
 '<p>The hit distance <code>t</code> is how far the pixel is from the camera. You can use it as a gray shade. Close pixels look bright. Far pixels look dark.</p><p>Output <code>vec3(1.0 - t * 0.2)</code> on hit. Output sky on miss. This is a rough depth view.</p><p>Reference: <a href="https://iquilezles.org/articles/raymarchingdf/" target="_blank" rel="noreferrer">IQ — Raymarching SDFs</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'sphere-tracing'), 'u0dEXd6T_aQ', 3,
 'Per-step visualization',
 '<p>The step count tells you a lot. Edges and grazing rays take many steps. Straight hits take few. Output the count and you can see the cost.</p><p>Track an int <code>iters</code> in the loop. Output <code>vec3(iters / 64.0)</code>. Bright pixels are expensive.</p><p>Reference: <a href="https://iquilezles.org/articles/nvscene2008/" target="_blank" rel="noreferrer">IQ — NVScene 2008 talk</a>.</p>',
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
((SELECT id FROM course WHERE slug = 'surface-normals'), 'hVfifCrsTSc', 0,
 'Central-difference normal',
 '<p>The normal points straight out of a surface. For an SDF, you can find it by sampling. Take six taps at <code>+epsilon</code> and <code>-epsilon</code> on each axis. Subtract pairs, then normalize.</p><p>Show it as a color with <code>0.5 + 0.5 * n</code>. A sphere shows a rainbow of axis colors.</p><p>Reference: <a href="https://iquilezles.org/articles/normalsSDF/" target="_blank" rel="noreferrer">IQ — Normals for SDFs</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'surface-normals'), '6tNC-7kiS8I', 1,
 'Normal as RGB on a torus',
 '<p>Swap the sphere for a torus. Now the rainbow wraps around the tube. The normals point outward and run through every direction as the surface curves.</p><p>This is the standard normal debug view. People use it to check geometry before adding lights.</p><p>Reference: <a href="https://iquilezles.org/articles/normalsSDF/" target="_blank" rel="noreferrer">IQ — Normals for SDFs</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'surface-normals'), 'hU4e94qsXZc', 2,
 'Tetrahedron normals',
 '<p>The 6-tap normal works but costs six SDF calls. A 4-tap version uses the corners of a tetrahedron. A tetrahedron is a four-corner pyramid shape. You get the same quality with two fewer calls.</p><p>The four offsets are <code>(1,-1,-1)</code>, <code>(-1,-1,1)</code>, <code>(-1,1,-1)</code>, <code>(1,1,1)</code>, scaled by epsilon. The sphere looks the same. The pixel cost goes down.</p><p>Reference: <a href="https://iquilezles.org/articles/normalsSDF/" target="_blank" rel="noreferrer">IQ — Normals for SDFs</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'surface-normals'), 'P2oCPl_JxcA', 3,
 'Tetrahedron normals on a torus',
 '<p>Use the 4-tap normal on the torus SDF. Same cheap method, more fun shape.</p><p>You''ll reuse this 4-tap form for the rest of the family. It is the standard cheap normal.</p><p>Reference: <a href="https://iquilezles.org/articles/normalsSDF/" target="_blank" rel="noreferrer">IQ — Normals for SDFs</a>.</p>',
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
((SELECT id FROM course WHERE slug = 'diffuse-lighting'), 'FsZLd2lCBdI', 0,
 'Lambertian dot',
 '<p>Diffuse light follows Lambert''s law. The brightness is <code>max(dot(n, l), 0.0)</code>. Here <code>n</code> is the surface normal. And <code>l</code> is the direction toward the light. Surfaces facing the light look brighter.</p><p>A negative dot means the surface faces away. You clamp to zero. Output the number on all three channels to see a gray shaded sphere.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'diffuse-lighting'), '7UuAMgw9ykc', 1,
 'Directional sun',
 '<p>Tint the diffuse term with a warm sun color. Use <code>vec3(1.0, 0.95, 0.8) * diff</code>.</p><p>The shape stays the same. But the lit side now looks like sunlight instead of plain gray.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'diffuse-lighting'), 'LTRI21yWBS8', 2,
 'Ambient floor',
 '<p>Plain diffuse leaves the dark side fully black. Add an ambient term to fill it in. Ambient is a constant color that lights every point a bit.</p><p>A cool blue ambient against a warm sun feels outdoors. Mix them: <code>vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'diffuse-lighting'), 'w3Qvls85ClU', 3,
 'Two-light setup',
 '<p>Real scenes have more than one light. Use a warm key and a cool fill. Aim them from opposite-ish directions.</p><p>Add them up: <code>diff1 * warm + diff2 * cool</code>. The result looks like sun and sky together.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ — Outdoors lighting</a>.</p>',
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
((SELECT id FROM course WHERE slug = 'soft-shadows'), 'Z7KFdyL36U0', 0,
 'Hard step shadow',
 '<p>A hard shadow is just a second march. Start from the hit point and shoot toward the light. If anything blocks the ray, the point is in shadow.</p><p>Push the start out by <code>0.01 * n</code> so the surface doesn''t block itself. Return 0 if blocked, 1 if clear. Multiply with the diffuse term.</p><p>Reference: <a href="https://iquilezles.org/articles/rmshadows/" target="_blank" rel="noreferrer">IQ — Raymarched soft shadows</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'soft-shadows'), 'yckztV5ltTY', 1,
 'Soft accumulation',
 '<p>For a soft shadow, don''t return 0 right away. Track the smallest value of <code>k*d/t</code> across the whole march. Rays that pass close to a surface but never hit give a partial shadow.</p><p>The constant <code>k</code> sets the softness. Smaller <code>k</code> means a blurrier shadow edge.</p><p>Reference: <a href="https://iquilezles.org/articles/rmshadows/" target="_blank" rel="noreferrer">IQ — Raymarched soft shadows</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'soft-shadows'), 'qJsdfh4K0aw', 2,
 'Tuning k',
 '<p>Raise <code>k</code> to <code>16.0</code>. The shadow edge gets sharper. It reads like a light that sits close to the surface.</p><p>Lower <code>k</code> values give a wide soft shadow. That looks like a far-off light.</p><p>Reference: <a href="https://iquilezles.org/articles/sphereshadow/" target="_blank" rel="noreferrer">IQ — Sphere shadow</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'soft-shadows'), 'nNC62N_E5dY', 3,
 'Sphere on ground with full lighting',
 '<p>Put it all together. A sphere sits on a ground plane. Use a warm sun and a cool ambient. The soft shadow only scales the direct light. Ambient stays full because it comes from all around.</p><p>This is the classic raymarched sphere shot you''ll see on lots of Shadertoy entries.</p><p>Reference: <a href="https://iquilezles.org/articles/rmshadows/" target="_blank" rel="noreferrer">IQ — Raymarched soft shadows</a>.</p>',
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
((SELECT id FROM course WHERE slug = 'sdf-3d-ops'), 'TLG-cK9XTpM', 0,
 'Union, intersect, subtract',
 '<p>SDFs have three simple combine ops. Union is <code>min(a, b)</code>. Intersection is <code>max(a, b)</code>. Subtraction is <code>max(a, -b)</code>. You get the shapes you''d expect.</p><p>Carve a small sphere out of a big one with subtract. You should see a clear dent on the side.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions/" target="_blank" rel="noreferrer">IQ — 3D SDFs (boolean ops)</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'sdf-3d-ops'), '8-aKpiS-z9M', 1,
 'Infinite repetition',
 '<p>Use <code>mod()</code> on the point before you call the SDF. The shape repeats forever. Center each cell with a half-period shift: <code>p.xz = mod(p.xz + 0.5, 1.0) - 0.5</code>.</p><p>One sphere becomes a grid of spheres. No extra cost.</p><p>Reference: <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ — SDF domain repetition</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'sdf-3d-ops'), '5c7nPSy_T_M', 2,
 'Finite repetition',
 '<p>Infinite copies are wasteful if you only need a few. You can clamp the cell index to limit the range.</p><p>Use <code>p.x -= 0.5 * clamp(floor(p.x/0.5 + 0.5), -2.0, 2.0)</code>. That gives five copies along x, then stops.</p><p>Reference: <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ — SDF domain repetition</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'sdf-3d-ops'), 'zc-V-hMIrr8', 3,
 'Axis fold',
 '<p>Mirror the world across an axis with <code>abs()</code>. The line <code>p.x = abs(p.x)</code> folds space across the y-z plane.</p><p>Put one sphere on the positive side and you get two. Fold two axes and you get four. This is the cheapest way to add symmetry.</p><p>Reference: <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf (mirror operators)</a>.</p>',
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
((SELECT id FROM course WHERE slug = 'sdf-fbm-detail'), 'AMPKI9l6IaI', 0,
 'Sphere plus fbm bumps',
 '<p>Subtract an fbm noise value from the sphere SDF and the surface gets bumps. fbm is fractal brownian motion. It is layered noise that makes natural-looking detail.</p><p>Small <code>AMP</code> values keep the SDF close to a real distance. Large ones break it. Start with <code>AMP = 0.05</code> for gentle bumps.</p><p>Reference: <a href="https://iquilezles.org/articles/fbmsdf/" target="_blank" rel="noreferrer">IQ — fbm detail in SDFs</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'sdf-fbm-detail'), 'h9wc7eeaHkM', 1,
 'Larger amplitude',
 '<p>Push <code>AMP</code> to <code>0.12</code>. The bumps get craggy. The tracer can still find the surface.</p><p>But each step now moves less. That is because the SDF is no longer a true distance. Many shaders multiply the SDF by <code>0.5</code> to fix this. You''ll see that trick in a later lesson.</p><p>Reference: <a href="https://iquilezles.org/articles/fbmsdf/" target="_blank" rel="noreferrer">IQ — fbm detail in SDFs</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'sdf-fbm-detail'), 'CL7nsnsDvAM', 2,
 'Higher frequency',
 '<p>Double the fbm input from <code>4.0</code> to <code>8.0</code>. The bumps get smaller and more crowded.</p><p>Keep the amplitude at <code>0.05</code>. The SDF still works well. This is how you change the detail size without breaking the surface.</p><p>Reference: <a href="https://iquilezles.org/articles/fbm/" target="_blank" rel="noreferrer">IQ — fbm</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'sdf-fbm-detail'), 'Xoz_PpTzWmY', 3,
 'Combine bumps with lighting',
 '<p>Add proper lighting and the bumpy sphere comes alive. Use a warm directional light and a cool ambient. Use the 4-tap normal too.</p><p>The normal taps sample the scene SDF. So they pick up the fbm bumps for free.</p><p>Reference: <a href="https://iquilezles.org/articles/fbmsdf/" target="_blank" rel="noreferrer">IQ — fbm detail in SDFs</a>.</p>',
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
((SELECT id FROM course WHERE slug = 'fog-and-ao'), 'j67c2TrN84Q', 0,
 'Linear depth fog',
 '<p>Fog mixes the surface color with the sky color based on distance. The simplest form is a straight ramp. Use <code>mix(color, sky, clamp(t / maxDist, 0, 1))</code>.</p><p>Far surfaces lose contrast and fade to sky. You get a clear depth cue for free.</p><p>Reference: <a href="https://iquilezles.org/articles/fog/" target="_blank" rel="noreferrer">IQ — Better fog</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'fog-and-ao'), 'wagyMhq2jqA', 1,
 'Exponential fog',
 '<p>Real fog falls off in a curve, not a line. Use <code>factor = 1.0 - exp(-t * density)</code>.</p><p>Set <code>density = 0.3</code>. Near surfaces stay clear. Far ones blend smoothly into the sky.</p><p>Reference: <a href="https://iquilezles.org/articles/fog/" target="_blank" rel="noreferrer">IQ — Better fog</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'fog-and-ao'), 'J2xhJR_1Hq4', 2,
 'Five-tap ambient occlusion',
 '<p>Ambient occlusion checks how much nearby stuff blocks the ambient light. Sample the SDF a few times along the normal. Each tap has a weight that drops with distance.</p><p>Gaps between the expected step and the real SDF mean something is in the way. The short 5-tap form is <code>ao -= (h - scene(p + h*n)) * pow(0.7, i)</code>.</p><p>Reference: <a href="https://iquilezles.org/articles/multiresaocc/" target="_blank" rel="noreferrer">IQ — Multiresolution ambient occlusion</a>.</p>',
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

((SELECT id FROM course WHERE slug = 'fog-and-ao'), 'Ud1X-GP_RQQ', 3,
 'AO and fog combined',
 '<p>Now put it all together. Combine diffuse times AO plus ambient. Then apply exponential fog over the result.</p><p>AO darkens crevices. Fog softens distance. Lighting gives the surface its shape. This recipe is the base for the bigger raymarched scenes in later courses.</p><p>Reference: <a href="https://iquilezles.org/articles/sphereao/" target="_blank" rel="noreferrer">IQ — Sphere ambient occlusion</a>.</p>',
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
