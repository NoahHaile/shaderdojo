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
    className?: string;
    /** Height passed to AceEditor AND set on the wrapper. Ace needs a parent
     *  with a definite height to compute its content area, so we mirror the
     *  prop onto an inline style. */
    height?: string;
}

export function Editor({ value, onChange, className, height = '100%' }: Props) {
    return (
        <div className={'w-full ' + (className ?? '')} style={{ height }}>
            <Suspense fallback={<EditorSkeleton />}>
                <AceEditor
                    mode="glsl"
                    theme="github"
                    value={value}
                    onChange={onChange}
                    name="lesson-editor"
                    width="100%"
                    height="100%"
                    fontSize={14}
                    tabSize={2}
                    showPrintMargin={false}
                    setOptions={{
                        useWorker: false,
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
        <div className="w-full h-full flex items-center justify-center bg-cream text-muted text-sm">
            Loading editor…
        </div>
    );
}
