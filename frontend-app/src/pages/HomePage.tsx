import { Link } from 'react-router-dom';
import { ShaderCanvas } from '../components/ShaderCanvas';

const HERO_SHADER = `// Original shader by Danilo Guanabara
void main() {
  vec3 c;
  float l, z = u_time;
  vec2 fragCoord = gl_FragCoord.xy;
  for (int i = 0; i < 3; i++) {
    vec2 uv, p = fragCoord / u_resolution.xy;
    uv = p;
    p -= 0.5;
    p.x *= u_resolution.x / u_resolution.y;
    z += 0.07;
    l = length(p);
    uv += p / l * (sin(z) + 1.0) * abs(sin(l * 9.0 - z - z));
    c[i] = 0.01 / length(mod(uv, 1.0) - 0.5);
  }
  gl_FragColor = vec4(c / l, 1.0);
}`;

export function HomePage() {
    return (
        <div className="max-w-6xl mx-auto px-4 py-12">
            <section className="grid lg:grid-cols-2 gap-10 items-center">
                <div>
                    <h1 className="text-4xl md:text-5xl font-semibold leading-tight tracking-tight text-ink">
                        Deconstruct & transform GPU code.
                    </h1>
                    <p className="mt-4 text-lg text-ink/70 max-w-prose">
                        ShaderDojo is a mix between{' '}
                        <a className="text-accent font-medium hover:underline" href="https://shadertoy.com/" target="_blank" rel="noreferrer">
                            ShaderToy
                        </a>{' '}and{' '}
                        <a className="text-accent font-medium hover:underline" href="https://projecteuler.net/" target="_blank" rel="noreferrer">
                            Project Euler
                        </a>. Take on shader challenges and bend light and math toward precise creative goals.
                    </p>
                    <div className="mt-6 flex gap-3">
                        <Link to="/courses" className="btn-primary">Start learning</Link>
                        <a className="btn-secondary" href="https://thebookofshaders.com/" target="_blank" rel="noreferrer">
                            The Book of Shaders
                        </a>
                    </div>
                </div>
                <div className="aspect-square w-full rounded-xl overflow-hidden border border-muted/30 bg-black shadow-sm">
                    <ShaderCanvas initialBody={HERO_SHADER} />
                </div>
            </section>

            <section className="mt-20 grid md:grid-cols-3 gap-4">
                <FeatureCard title="Write, run, verify">
                    Each lesson runs your GLSL in the browser and compares the rendered pixels
                    against the expected output.
                </FeatureCard>
                <FeatureCard title="One concept per step">
                    Lessons stay short on purpose: uniforms, shaping functions, distance fields,
                    noise — one at a time.
                </FeatureCard>
                <FeatureCard title="Build something you keep">
                    Courses are sequential. Finish one and you have a portfolio-grade shader, not
                    just a stack of one-offs.
                </FeatureCard>
            </section>
        </div>
    );
}

function FeatureCard({ title, children }: { title: string; children: React.ReactNode }) {
    return (
        <div className="card">
            <h3 className="text-base font-semibold mb-2">{title}</h3>
            <p className="text-sm text-ink/70 leading-relaxed">{children}</p>
        </div>
    );
}
