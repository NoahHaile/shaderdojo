import { lazy, Suspense } from 'react';

// react-ace pulls in ~600KB of Ace itself — load it only when an editor is actually shown.
const AceEditor = lazy(async () => {
    const mod = await import('react-ace');
    // Mode + theme imports must be after react-ace.
    await import('ace-builds/src-noconflict/mode-glsl');
    await import('ace-builds/src-noconflict/theme-github');
    await import('ace-builds/src-noconflict/ext-language_tools');
    return { default: mod.default };
});

interface Props {
    value: string;
    onChange: (next: string) => void;
    /** Tailwind classes for the wrapper, controls editor size. */
    className?: string;
    /** Height passed directly to AceEditor. Defaults to 100%. */
    height?: string;
}

export function Editor({ value, onChange, className, height = '100%' }: Props) {
    return (
        <div className={'min-h-[240px] ' + (className ?? '')}>
            <Suspense fallback={<EditorSkeleton />}>
                <AceEditor
                    mode="glsl"
                    theme="github"
                    value={value}
                    onChange={onChange}
                    name="lesson-editor"
                    width="100%"
                    height={height}
                    fontSize={14}
                    tabSize={2}
                    showPrintMargin={false}
                    setOptions={{
                        useWorker: false,           // workers in Vite need extra wiring; off keeps it simple
                        showLineNumbers: true,
                        highlightActiveLine: true,
                    }}
                />
            </Suspense>
        </div>
    );
}

function EditorSkeleton() {
    return (
        <div className="w-full h-full min-h-[240px] flex items-center justify-center bg-cream border border-muted/30 rounded-md text-muted text-sm">
            Loading editor…
        </div>
    );
}
