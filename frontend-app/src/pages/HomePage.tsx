import { Link } from 'react-router-dom';
import { ShaderCanvas } from '../components/ShaderCanvas';
import { RoadmapGraph } from '../components/RoadmapGraph';

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
                        Imagine you had control over every pixel on the screen
                    </h1>
                    <p className="mt-3 text-base text-ink/60 max-w-prose">
                        ShaderDojo teaches a range of techniques that allow you to do this effectively. It is a mix between{' '}
                        <a className="text-accent font-medium hover:underline" href="https://shadertoy.com/" target="_blank" rel="noreferrer">
                            ShaderToy
                        </a>{' '}and{' '}
                        <a className="text-accent font-medium hover:underline" href="https://www.freecodecamp.org/" target="_blank" rel="noreferrer">
                            freeCodeCamp
                        </a>.
                    </p>
                    <div className="mt-6 flex gap-3">
                        <Link to="/courses" className="btn-primary">Start learning</Link>
                        <Link to="/reference" className="btn-secondary">Reference</Link>
                    </div>
                </div>
                <div className="aspect-square w-full rounded-xl overflow-hidden border border-muted/30 bg-black shadow-sm">
                    <ShaderCanvas initialBody={HERO_SHADER} />
                </div>
            </section>

            <section className="mt-16">
                <header className="mb-6">
                    <h2 className="text-2xl md:text-3xl font-semibold tracking-tight">The roadmap</h2>
                    <p className="mt-1 text-ink/60 text-sm max-w-prose">
                        Each course builds on the ones above it. Start at the top with Orientation
                        and follow the arrows. Click any node to jump in.
                    </p>
                </header>
                <RoadmapGraph />
            </section>
        </div>
    );
}
