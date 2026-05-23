import type { Config } from 'tailwindcss';

export default {
    content: ['./index.html', './src/**/*.{ts,tsx}'],
    theme: {
        extend: {
            colors: {
                // ShaderDojo identity — must match the legacy site.
                primary:   '#ffff83',  // yellow highlight (donate box, pill highlights)
                accent:    '#fe7e7e',  // salmon-pink, used for links + primary buttons
                accentDim: '#DCCDE8',  // lavender secondary accent
                ink:       '#333',     // body text
                muted:     '#AAA',     // dim text / borders
                cream:     '#fafafa',  // softer-than-white background for cards
            },
            fontFamily: {
                sans: ['Lexend', 'system-ui', '-apple-system', 'Segoe UI', 'sans-serif'],
                mono: ['JetBrains Mono', 'ui-monospace', 'SF Mono', 'Menlo', 'monospace'],
            },
            borderRadius: {
                xl: '1rem',
            },
        },
    },
    plugins: [],
} satisfies Config;
