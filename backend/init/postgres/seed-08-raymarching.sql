\c shader_dojo;

-- Family G, Raymarching (9 courses, 36 lessons)

INSERT INTO lesson (course_id, slug, display_order, title, description, starter_fragment_shader, canonical_fragment_shader) VALUES

-- ===== Course: ray-pinhole-camera =====
((SELECT id FROM course WHERE slug = 'ray-pinhole-camera'), 'bVzyIUm-AXM', 0,
 'Ray direction colormap',
 '<p>Raymarching needs a camera. For each pixel, build a ray. A ray is a 3D line with a start point <code>ro</code> and a direction <code>rd</code>. The direction must be a unit vector.</p><p>There''s no scene yet, so paint the ray direction as color: <code>0.5 + 0.5 * rd</code> maps it to <code>[0, 1]</code>. Red rises with +X, green with +Y. The smooth gradient is a "sky" that shows where every ray is pointing, proof your camera is dispatching real 3D directions, not flat UVs.</p><p>Reference: <a href="https://iquilezles.org/articles/raymarchingdf/" target="_blank" rel="noreferrer">IQ, Raymarching SDFs</a>.</p>',
 'void main() {
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
 '<p>The camera start <code>ro</code> is just a 3D point. You can move it. Try <code>vec3(0.5, 0.2, 3.0)</code>. That shifts the camera right and up.</p><p>Notice the sky-gradient barely budges, moving <code>ro</code> alone keeps every ray pointing the same way. The view shifts, but the directions don''t. To rotate the gaze you also need to rebuild <code>rd</code>, which is the next lesson.</p><p>Reference: <a href="https://iquilezles.org/articles/raytracing/" target="_blank" rel="noreferrer">IQ, Oldschool raytracing</a>.</p>',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
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
 '<p>A lookat camera aims at a target point <code>ta</code>. You build three axes from <code>ro</code> and <code>ta</code>. Forward is <code>f = normalize(ta - ro)</code>. Right is <code>r = normalize(cross(f, world_up))</code>. Up is <code>u = cross(r, f)</code>.</p><p>The ray direction is <code>r*uv.x + u*uv.y + f*focal</code>, normalized. Now the sky-gradient rotates with the aim, move <code>ta</code> and you''ll see the colored "sky" sweep across the screen, proof the camera is really turning.</p><p>Reference: <a href="https://iquilezles.org/articles/raytracing/" target="_blank" rel="noreferrer">IQ, Oldschool raytracing</a>.</p>',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.5, 0.2, 3.0);
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
 '<p>The focal length sets the field of view. Field of view is how wide the lens sees. Swap the fixed <code>-1.5</code> for an angle-based form. Use <code>rd = normalize(vec3(uv * tan(fov/2), -1.0))</code>.</p><p>A bigger angle means a wider lens. Here <code>fov = 1.0</code> radian (about 57 degrees). Watch the colored sky-gradient compress or spread as you change the angle, the spread of colors across the frame is literally the camera''s cone of vision.</p><p>Reference: <a href="https://iquilezles.org/articles/raytracing/" target="_blank" rel="noreferrer">IQ, Oldschool raytracing</a>.</p>',
 'void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 ta = vec3(0.0);
    vec3 f = normalize(ta - ro);
    vec3 r = normalize(cross(f, vec3(0.0, 1.0, 0.0)));
    vec3 u = cross(r, f);
    vec3 rd = normalize(r * uv.x + u * uv.y + f * 1.5);
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
 '<p>A 3D SDF gives a number for any point. Negative inside the shape. Positive outside. Zero on the surface. The sphere SDF is <code>length(p) - r</code>.</p><p>This lesson raymarches the SDF and lights it with a warm sun plus a cool ambient. Right now <code>scene</code> returns a huge constant, so every ray misses and you only see sky. Replace the body with <code>return length(p) - 0.6;</code> and a softly-shaded ball appears.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions/" target="_blank" rel="noreferrer">IQ, 3D SDFs</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return 1000.0;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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

    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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

    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-3d-primitives'), 'j2k8NNueePM', 1,
 'Box',
 '<p>The box SDF has two parts. First take <code>q = abs(p) - halfSize</code>. Then the distance is <code>length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0)</code>.</p><p>The first term works for points outside the box. The second works for points inside. Drop it into <code>scene</code> and the same raymarched, lit scaffold renders a softly-shaded box, only the SDF changes.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions/" target="_blank" rel="noreferrer">IQ, 3D SDFs</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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

    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    vec3 q = abs(p) - vec3(0.5, 0.4, 0.4);
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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

    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-3d-primitives'), 'zhMoauT9MJQ', 2,
 'Ground plane',
 '<p>A flat ground plane is the simplest SDF. For the plane <code>y = -h</code>, use <code>p.y + h</code>. It is negative below the plane and positive above.</p><p>Swap the box SDF for <code>return p.y + 0.4;</code> and the same raymarched, lit scaffold draws a horizon-style scene: a lit floor falling away to sky.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions/" target="_blank" rel="noreferrer">IQ, 3D SDFs</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    vec3 q = abs(p) - vec3(0.5, 0.4, 0.4);
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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

    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return p.y + 0.4;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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

    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-3d-primitives'), 'yfswq5aK_l8', 3,
 'Torus',
 '<p>A torus is a donut shape. It is a circle of circles. Build a 2D point <code>q = vec2(length(p.xz) - R, p.y)</code>. The x part is the distance to the big ring on the xz plane. The y part is the height.</p><p>Then <code>length(q) - r</code> is the distance to the tube. <code>R</code> is the ring size and <code>r</code> is the tube size. Drop the SDF into the lit raymarched scaffold and a softly-shaded donut shows up.</p><p>Reference: <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return p.y + 0.4;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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

    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    vec2 q = vec2(length(p.xz) - 0.5, p.y);
    return length(q) - 0.18;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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

    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: sphere-tracing =====
((SELECT id FROM course WHERE slug = 'sphere-tracing'), 'xu3F6SH4e5c', 0,
 'A 64-step march',
 '<p>Sphere tracing walks along the ray. At each step, you jump forward by the SDF value. That is the biggest safe jump. It will not pass through a surface.</p><p>Loop up to 64 times. Add <code>scene(ro + t*rd)</code> to <code>t</code> each step. Stop when the distance drops below a small number (you hit). Or stop when <code>t</code> gets too big (you missed). Shade the hit with <code>cheap_light(normal_at(p))</code> and a softly-shaded ball sits on a blue sky.</p><p>Reference: <a href="https://iquilezles.org/articles/raymarchingdf/" target="_blank" rel="noreferrer">IQ, Raymarching SDFs</a>.</p>',
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
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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

    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sphere-tracing'), 'u4Qn8Ib_h_Q', 1,
 'Sky fallback',
 '<p>Every ray that doesn''t hit still needs a color. The "miss" path here returns the sky, <code>vec3(0.7, 0.85, 1.0)</code>, and the lit sphere sits cleanly on top of it.</p><p>The whole background is one branch: <code>col</code> starts at the sky color, and only gets overwritten when the march hits. No extra work for misses.</p><p>Reference: <a href="https://iquilezles.org/articles/nvscene2008/" target="_blank" rel="noreferrer">IQ, NVScene 2008 talk</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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

    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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

    vec3 sky = vec3(0.7, 0.85, 1.0);
    vec3 col = sky;
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sphere-tracing'), 'Xvj_ruSggEU', 2,
 'Depth tint',
 '<p>The hit distance <code>t</code> tells you how far the pixel is from the camera. Mix the lit color toward the sky as <code>t</code> grows: <code>mix(col, fog, t * 0.1)</code>.</p><p>Near surfaces stay vivid, far ones wash into the sky. It''s a cheap depth cue without a real fog model, the lit sphere is still there, just tinted by distance.</p><p>Reference: <a href="https://iquilezles.org/articles/raymarchingdf/" target="_blank" rel="noreferrer">IQ, Raymarching SDFs</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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

    vec3 sky = vec3(0.7, 0.85, 1.0);
    vec3 col = sky;
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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

    vec3 fog = vec3(0.7, 0.85, 1.0);
    vec3 col = fog;
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
        col = mix(col, fog, clamp(t * 0.1, 0.0, 1.0));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sphere-tracing'), 'u0dEXd6T_aQ', 3,
 'Per-step cost visualization',
 '<p>The step count tells you a lot. Edges and grazing rays take many steps. Straight hits take few. Track an int <code>iters</code> and you can see exactly which pixels were expensive.</p><p>Instead of replacing the picture with a gray colormap, mix the lit color toward red by <code>iters / 64.0</code>. The sphere keeps its shape and lighting, but its edges and silhouette glow red, visualizing loop cost without losing the scene.</p><p>Reference: <a href="https://iquilezles.org/articles/nvscene2008/" target="_blank" rel="noreferrer">IQ, NVScene 2008 talk</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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

    vec3 fog = vec3(0.7, 0.85, 1.0);
    vec3 col = fog;
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
        col = mix(col, fog, clamp(t * 0.1, 0.0, 1.0));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = normalize(vec3(uv, -1.5));

    float t = 0.0;
    bool hit = false;
    int iters = 0;
    for (int i = 0; i < 64; i++) {
        iters = i + 1;
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }

    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    float cost = float(iters) / 64.0;
    col = mix(col, vec3(1.0, 0.2, 0.2), cost);
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: surface-normals =====
((SELECT id FROM course WHERE slug = 'surface-normals'), 'hVfifCrsTSc', 0,
 'Normals from finite differences',
 '<p>The normal of a surface points straight outward. For an SDF, you can build it from the gradient. Sample the SDF a tiny step in each axis: <code>(scene(p + dx) - scene(p - dx)) / (2 * eps)</code>. That gives you the rate of change along x. Do the same for y and z, then normalize. This is the 4-tap central difference.</p><p>To prove it works, render the normal directly as color with <code>0.5 + 0.5 * normal</code>. A sphere becomes a smooth rainbow ball, red goes with +X, green with +Y, blue with +Z. Once you see this, you know the geometry is correct.</p><p>Reference: <a href="https://iquilezles.org/articles/normalsSDF/" target="_blank" rel="noreferrer">IQ, Normals for SDFs</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        // lighting goes here
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal_at(p);
        col = 0.5 + 0.5 * n;
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'surface-normals'), 'hU4e94qsXZc', 1,
 'Apply normals: simple shading',
 '<p>Now that you have a normal, you can light the surface. The cheapest useful light is Lambertian diffuse: <code>diff = max(dot(n, l), 0.0)</code>. Bright where the surface faces the light, dark where it faces away. Add a small ambient term so the shadow side isn''t pitch black.</p><p>The <code>cheap_light</code> helper at the top does exactly that, warm sun plus cool ambient. Pass it your normal and it returns a color. Suddenly the sphere reads as a real 3D ball instead of a flat circle.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ, Outdoors lighting</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal_at(p);
        col = 0.5 + 0.5 * n;
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: diffuse-lighting =====
((SELECT id FROM course WHERE slug = 'diffuse-lighting'), 'FsZLd2lCBdI', 0,
 'Diffuse lighting',
 '<p>Diffuse light follows Lambert''s law. The brightness of a surface depends on the angle between its normal and the light direction: <code>diff = max(dot(n, l), 0.0)</code>. The <code>max</code> clamps negative dots (back-facing surfaces) to zero.</p><p>Multiply that by a warm sun color and add a cool ambient term so the shadow side doesn''t turn pure black. The whole hit-branch math is just <code>warm * diff + ambient</code>. This is the same recipe the <code>cheap_light</code> helper uses, here we write it out so the math is on the page.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ, Outdoors lighting</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = vec3(0.0);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal_at(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(1.0, 0.95, 0.8) * diff + vec3(0.2, 0.25, 0.35) * 0.4;
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'diffuse-lighting'), 'LTRI21yWBS8', 1,
 'Multi-light',
 '<p>One light is never enough. Real outdoor scenes have a warm sun from one side and a cooler sky-fill from the other. Compute a diffuse term for each light, scale by its color, and sum them. Add an ambient term on top for the shadow side.</p><p>Here the sun comes from above-right with the standard warm tint; the fill comes from the opposite direction in a cool blue, dialed back to 60% so it doesn''t fight the key light. The result reads as natural three-quarter lighting.</p><p>Reference: <a href="https://iquilezles.org/articles/outdoorslighting/" target="_blank" rel="noreferrer">IQ, Outdoors lighting</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal_at(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        col = vec3(1.0, 0.95, 0.8) * diff + vec3(0.2, 0.25, 0.35) * 0.4;
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    return length(p) - 0.6;
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal_at(p);
        vec3 sun_dir = normalize(vec3(0.5, 0.8, 0.3));
        vec3 fill_dir = normalize(vec3(-0.5, 0.4, -0.3));
        float sun_diff = max(dot(n, sun_dir), 0.0);
        float fill_diff = max(dot(n, fill_dir), 0.0);
        vec3 sun = vec3(1.0, 0.95, 0.8) * sun_diff;
        vec3 fill = vec3(0.4, 0.6, 0.9) * 0.6 * fill_diff;
        vec3 ambient = vec3(0.2, 0.25, 0.35) * 0.4;
        col = sun + fill + ambient;
    }
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: soft-shadows =====
((SELECT id FROM course WHERE slug = 'soft-shadows'), 'yckztV5ltTY', 0,
 'Soft shadows',
 '<p>Hard shadows are a binary test, blocked or not. Soft shadows are an estimate of how close the shadow ray came to being blocked. The IQ trick: run a second march from the surface toward the light, and keep a running min of <code>k * d / t</code> at every step. If the ray squeaked past a surface, that ratio gets small, and the point ends up partly shadowed.</p><p>Multiply the shadow value into the diffuse term. The constant <code>k</code> controls hardness, higher <code>k</code> (try <code>16.0</code>) gives sharper edges, lower (try <code>4.0</code>) gives softer. <code>k = 8.0</code> is a good starting point.</p><p>Reference: <a href="https://iquilezles.org/articles/rmshadows/" target="_blank" rel="noreferrer">IQ, Raymarched soft shadows</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    float sphere = length(p - vec3(0.0, 0.2, 0.0)) - 0.6;
    float ground = p.y + 0.6;
    return min(sphere, ground);
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal_at(p);
        vec3 sun_dir = normalize(vec3(0.5, 0.8, 0.3));
        vec3 fill_dir = normalize(vec3(-0.5, 0.4, -0.3));
        float sun_diff = max(dot(n, sun_dir), 0.0);
        float fill_diff = max(dot(n, fill_dir), 0.0);
        vec3 sun = vec3(1.0, 0.95, 0.8) * sun_diff;
        vec3 fill = vec3(0.4, 0.6, 0.9) * 0.6 * fill_diff;
        vec3 ambient = vec3(0.2, 0.25, 0.35) * 0.4;
        col = sun + fill + ambient;
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    float sphere = length(p - vec3(0.0, 0.2, 0.0)) - 0.6;
    float ground = p.y + 0.6;
    return min(sphere, ground);
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

float softshadow(vec3 ro, vec3 rd, float k) {
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
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal_at(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        float sh = softshadow(p + 0.01 * n, l, 8.0);
        col = vec3(1.0, 0.95, 0.8) * diff * sh + vec3(0.2, 0.25, 0.35) * 0.4;
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'soft-shadows'), 'nNC62N_E5dY', 1,
 'Lit and shadowed scene',
 '<p>Put it all together. Sphere sitting on a ground plane, lit by a warm directional sun with a cool ambient fill. The soft shadow scales only the direct diffuse term, ambient stays unblocked because it represents indirect light from every direction.</p><p>One small touch makes it sing: a thin exponential fog that fades the far edge of the ground into the sky color. That is the classic raymarched portrait shot, sphere, ground, soft shadow, fog. Everything you''ve learned in this family in a single frame.</p><p>Reference: <a href="https://iquilezles.org/articles/rmshadows/" target="_blank" rel="noreferrer">IQ, Raymarched soft shadows</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    float sphere = length(p - vec3(0.0, 0.2, 0.0)) - 0.6;
    float ground = p.y + 0.6;
    return min(sphere, ground);
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

float softshadow(vec3 ro, vec3 rd, float k) {
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
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal_at(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        float sh = softshadow(p + 0.01 * n, l, 8.0);
        col = vec3(1.0, 0.95, 0.8) * diff * sh + vec3(0.2, 0.25, 0.35) * 0.4;
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}

float scene(vec3 p) {
    float sphere = length(p - vec3(0.0, 0.2, 0.0)) - 0.6;
    float ground = p.y + 0.6;
    return min(sphere, ground);
}

vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}

float softshadow(vec3 ro, vec3 rd, float k) {
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
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal_at(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        float sh = softshadow(p + 0.01 * n, l, 8.0);
        vec3 lit = vec3(1.0, 0.95, 0.8) * diff * sh + vec3(0.2, 0.25, 0.35) * 0.4;
        float fog = 1.0 - exp(-0.08 * t);
        col = mix(lit, vec3(0.7, 0.85, 1.0), fog);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: sdf-3d-ops =====
((SELECT id FROM course WHERE slug = 'sdf-3d-ops'), 'TLG-cK9XTpM', 0,
 'Union, intersect, subtract',
 '<p>Three combine ops cover almost everything: <code>min(a, b)</code> is union, <code>max(a, b)</code> is intersection, and <code>max(-a, b)</code> subtracts <code>a</code> from <code>b</code>.</p><p>Start from a union of two spheres so you can see the shapes overlap. Switch the return to <code>max(-bite, big)</code> and the small sphere carves a clean dent out of the big one.</p><p>Reference: <a href="https://iquilezles.org/articles/distfunctions/" target="_blank" rel="noreferrer">IQ, 3D SDFs (boolean ops)</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    float big = length(p) - 0.5;
    float bite = length(p - vec3(0.3, 0.0, 0.0)) - 0.4;
    return min(big, bite);
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    float big = length(p) - 0.5;
    float bite = length(p - vec3(0.3, 0.0, 0.0)) - 0.4;
    return max(-bite, big);
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-3d-ops'), '8-aKpiS-z9M', 1,
 'Infinite repetition',
 '<p>Wrap the point with <code>mod()</code> before calling the SDF and the shape tiles forever. The half-period shift <code>p.xz = mod(p.xz + 0.5, 1.0) - 0.5</code> centers each cell on its tile.</p><p>One sphere becomes an infinite grid of spheres in the xz plane, and the marcher pays no extra cost per copy.</p><p>Reference: <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ, SDF domain repetition</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    float big = length(p) - 0.5;
    float bite = length(p - vec3(0.3, 0.0, 0.0)) - 0.4;
    return max(-bite, big);
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    p.xz = mod(p.xz + 0.5, 1.0) - 0.5;
    return length(p) - 0.3;
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-3d-ops'), '5c7nPSy_T_M', 2,
 'Finite repetition',
 '<p>Infinite tiling is great until you only want a row of five. Clamp the cell index instead: <code>p.x = p.x - 0.5 * clamp(floor(p.x / 0.5 + 0.5), -2.0, 2.0)</code> repeats along x but stops after a few cells in each direction.</p><p>Tighten the bounds to shrink the row; widen them to grow it.</p><p>Reference: <a href="https://iquilezles.org/articles/sdfrepetition/" target="_blank" rel="noreferrer">IQ, SDF domain repetition</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    p.xz = mod(p.xz + 0.5, 1.0) - 0.5;
    return length(p) - 0.3;
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    p.x = p.x - 0.5 * clamp(floor(p.x / 0.5 + 0.5), -2.0, 2.0);
    return length(p) - 0.2;
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-3d-ops'), 'zc-V-hMIrr8', 3,
 'Axis fold',
 '<p><code>abs</code> on a coordinate mirrors space across that axis. Folding <code>p.x</code> and <code>p.z</code> reflects one quadrant of the xz plane into all four around the origin.</p><p>Place one sphere at <code>(0.4, 0.0, 0.4)</code> and you get four, the cheapest way to add symmetry.</p><p>Reference: <a href="https://mercury.sexy/hg_sdf/" target="_blank" rel="noreferrer">hg_sdf (mirror operators)</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    p.x = p.x - 0.5 * clamp(floor(p.x / 0.5 + 0.5), -2.0, 2.0);
    return length(p) - 0.2;
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    p.x = abs(p.x);
    p.z = abs(p.z);
    return length(p - vec3(0.4, 0.0, 0.4)) - 0.3;
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: sdf-fbm-detail =====
((SELECT id FROM course WHERE slug = 'sdf-fbm-detail'), 'AMPKI9l6IaI', 0,
 'Sphere with fbm bumps',
 '<p>Subtract a noise value from a sphere SDF and the surface picks up organic bumps. fbm, fractal brownian motion, stacks octaves of value noise so the detail looks natural rather than uniform.</p><p>Try changing the <code>0.08</code> amplitude or the <code>5.0</code> frequency to taste, small values give fine wrinkles, larger ones give craggy planets. Push amplitude too far and the SDF stops being a true distance and the marcher starts to overshoot.</p><p>Reference: <a href="https://iquilezles.org/articles/fbmsdf/" target="_blank" rel="noreferrer">IQ, fbm detail in SDFs</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
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
    return length(p) - 0.6;
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
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
    return length(p) - 0.6 - 0.08 * fbm(p.xy * 5.0 + p.z * 5.0);
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'sdf-fbm-detail'), 'Xoz_PpTzWmY', 1,
 'Full bumpy scene',
 '<p>The bumpy sphere is only half a scene. Add a ground plane, a soft shadow so it casts onto the floor, an ambient term so it never goes pitch black, and a touch of distance fog so the horizon recedes.</p><p>This is the family''s capstone, every later raymarched scene in ShaderDojo is some variation on this same recipe of SDF + lighting + shadow + ambient + fog.</p><p>Reference: <a href="https://iquilezles.org/articles/rmshadows/" target="_blank" rel="noreferrer">IQ, Soft shadows in raymarching</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
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
    return length(p) - 0.6 - 0.08 * fbm(p.xy * 5.0 + p.z * 5.0);
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
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
    float bumpy = length(p) - 0.6 - 0.08 * fbm(p.xy * 5.0 + p.z * 5.0);
    float ground = p.y + 0.6;
    return min(bumpy, ground);
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
float soft_shadow(vec3 ro, vec3 rd) {
    float res = 1.0;
    float t = 0.02;
    for (int i = 0; i < 32; i++) {
        float d = scene(ro + t * rd);
        if (d < 0.001) return 0.0;
        res = min(res, 8.0 * d / t);
        t += d;
        if (t > 6.0) break;
    }
    return clamp(res, 0.0, 1.0);
}
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
    vec3 sky = vec3(0.7, 0.85, 1.0);
    vec3 col = sky;
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal_at(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        float sh = soft_shadow(p + 0.01 * n, l);
        vec3 ambient = vec3(0.2, 0.25, 0.35) * 0.4;
        col = ambient + vec3(1.0, 0.95, 0.8) * diff * sh;
        col = mix(col, sky, 1.0 - exp(-t * 0.15));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

-- ===== Course: fog-and-ao =====
((SELECT id FROM course WHERE slug = 'fog-and-ao'), 'j67c2TrN84Q', 0,
 'Linear depth fog',
 '<p>Fog is a ramp from surface color to sky color driven by depth. The simplest form is linear: <code>col = mix(col, sky, clamp(t / 8.0, 0.0, 1.0));</code>, surfaces near the camera stay sharp, surfaces past <code>t = 8</code> are pure sky.</p><p>That single line gives you a depth cue for free and softens the silhouette of the ground.</p><p>Reference: <a href="https://iquilezles.org/articles/fog/" target="_blank" rel="noreferrer">IQ, Better fog</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    float sph = length(p) - 0.5;
    float ground = p.y + 0.3;
    return min(sph, ground);
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    float sph = length(p) - 0.5;
    float ground = p.y + 0.3;
    return min(sph, ground);
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
        col = mix(col, vec3(0.7, 0.85, 1.0), clamp(t / 8.0, 0.0, 1.0));
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'fog-and-ao'), 'wagyMhq2jqA', 1,
 'Exponential fog',
 '<p>Real fog doesn''t cut off at a fixed distance, it falls off in a curve. Swap the linear ramp for <code>float f = 1.0 - exp(-t * 0.3); col = mix(col, sky, f);</code> and the falloff matches what your eye expects.</p><p>Density controls how fast the curve climbs. Bump <code>0.3</code> up for thick weather, drop it for a hazy summer day.</p><p>Reference: <a href="https://iquilezles.org/articles/fog/" target="_blank" rel="noreferrer">IQ, Better fog</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    float sph = length(p) - 0.5;
    float ground = p.y + 0.3;
    return min(sph, ground);
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
        col = mix(col, vec3(0.7, 0.85, 1.0), clamp(t / 8.0, 0.0, 1.0));
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    float sph = length(p) - 0.5;
    float ground = p.y + 0.3;
    return min(sph, ground);
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
        float f = 1.0 - exp(-t * 0.3);
        col = mix(col, vec3(0.7, 0.85, 1.0), f);
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'fog-and-ao'), 'J2xhJR_1Hq4', 2,
 'Five-tap ambient occlusion',
 '<p>Ambient occlusion darkens the spots where geometry crowds itself, under the sphere, in corners, where the ground meets the ball. Five short rays into the normal direction are enough: each tap compares the expected step <code>h</code> with the real SDF and subtracts the gap, weighted by <code>pow(0.7, i)</code> so far taps count less.</p><p>Multiply the lit color by the AO factor and the scene gets a free grounding shadow.</p><p>Reference: <a href="https://iquilezles.org/articles/multiresaocc/" target="_blank" rel="noreferrer">IQ, Multiresolution ambient occlusion</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    float sph = length(p) - 0.5;
    float ground = p.y + 0.3;
    return min(sph, ground);
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
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
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        col = cheap_light(normal_at(p));
        float f = 1.0 - exp(-t * 0.3);
        col = mix(col, vec3(0.7, 0.85, 1.0), f);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    float sph = length(p) - 0.5;
    float ground = p.y + 0.3;
    return min(sph, ground);
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
float ambient_occlusion(vec3 p, vec3 n) {
    float a = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = scene(p + h * n);
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
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal_at(p);
        float ao = ambient_occlusion(p, n);
        col = cheap_light(n);
        col *= ao;
    }
    gl_FragColor = vec4(col, 1.0);
}'),

((SELECT id FROM course WHERE slug = 'fog-and-ao'), 'Ud1X-GP_RQQ', 3,
 'AO and fog combined',
 '<p>The capstone. You have all four ingredients now: diffuse lighting, soft shadow, ambient occlusion, exponential fog. The recipe is <code>(ambient + diffuse * shadow) * ao</code>, then blend the whole thing toward the sky with the exp fog factor.</p><p>This is the base lighting setup every raymarched scene later in ShaderDojo builds on, sky, ambient, key light, shadow, AO, fog.</p><p>Reference: <a href="https://iquilezles.org/articles/sphereao/" target="_blank" rel="noreferrer">IQ, Sphere ambient occlusion</a>.</p>',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    float sph = length(p) - 0.5;
    float ground = p.y + 0.3;
    return min(sph, ground);
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
float ambient_occlusion(vec3 p, vec3 n) {
    float a = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = scene(p + h * n);
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
    for (int i = 0; i < 64; i++) {
        vec3 p = ro + t * rd;
        float d = scene(p);
        if (d < 0.001) { hit = true; break; }
        if (t > 10.0) break;
        t += d;
    }
    vec3 col = vec3(0.7, 0.85, 1.0);
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal_at(p);
        // your job: combine diffuse, AO, and fog
        col = cheap_light(n);
    }
    gl_FragColor = vec4(col, 1.0);
}',
 'vec3 cheap_light(vec3 normal) {
    vec3 light = normalize(vec3(0.5, 0.8, 0.3));
    float diff = max(dot(normal, light), 0.0);
    return vec3(0.2, 0.25, 0.35) * 0.4 + vec3(1.0, 0.95, 0.8) * diff;
}
float scene(vec3 p) {
    float sph = length(p) - 0.5;
    float ground = p.y + 0.3;
    return min(sph, ground);
}
vec3 normal_at(vec3 p) {
    float e = 0.001;
    return normalize(vec3(
        scene(p + vec3(e, 0, 0)) - scene(p - vec3(e, 0, 0)),
        scene(p + vec3(0, e, 0)) - scene(p - vec3(0, e, 0)),
        scene(p + vec3(0, 0, e)) - scene(p - vec3(0, 0, e))
    ));
}
float ambient_occlusion(vec3 p, vec3 n) {
    float a = 1.0;
    for (int i = 0; i < 5; i++) {
        float h = 0.01 + 0.12 * float(i) / 4.0;
        float d = scene(p + h * n);
        a -= (h - d) * pow(0.7, float(i));
    }
    return clamp(a, 0.0, 1.0);
}
float soft_shadow(vec3 ro, vec3 rd) {
    float res = 1.0;
    float t = 0.02;
    for (int i = 0; i < 32; i++) {
        float d = scene(ro + t * rd);
        if (d < 0.001) return 0.0;
        res = min(res, 8.0 * d / t);
        t += d;
        if (t > 6.0) break;
    }
    return clamp(res, 0.0, 1.0);
}
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
    vec3 sky = vec3(0.7, 0.85, 1.0);
    vec3 col = sky;
    if (hit) {
        vec3 p = ro + t * rd;
        vec3 n = normal_at(p);
        vec3 l = normalize(vec3(0.5, 0.8, 0.3));
        float diff = max(dot(n, l), 0.0);
        float sh = soft_shadow(p + 0.01 * n, l);
        float ao = ambient_occlusion(p, n);
        vec3 ambient = vec3(0.2, 0.25, 0.35) * 0.4;
        col = (ambient + vec3(1.0, 0.95, 0.8) * diff * sh) * ao;
        col = mix(col, sky, 1.0 - exp(-t * 0.3));
    }
    gl_FragColor = vec4(col, 1.0);
}');
