interface Props {
    value: number;
    max: number;
    /** Optional class on the outer track (size, margin, etc.). */
    className?: string;
    /** Track height; defaults to 6px. */
    height?: number;
    /** Show "N / M" text beside the bar. */
    showCount?: boolean;
    /** Tailwind colour for the fill. Defaults to accent (salmon). */
    fillClassName?: string;
}

export function ProgressBar({
    value, max, className, height = 6, showCount, fillClassName = 'bg-accent',
}: Props) {
    const clampedMax = Math.max(0, max);
    const clamped = Math.max(0, Math.min(value, clampedMax));
    const pct = clampedMax === 0 ? 0 : Math.round((clamped / clampedMax) * 100);

    const bar = (
        <div
            className={'w-full rounded-full bg-cream overflow-hidden ' + (className ?? '')}
            style={{ height }}
            role="progressbar"
            aria-valuemin={0}
            aria-valuemax={clampedMax}
            aria-valuenow={clamped}>
            <div
                className={'h-full transition-[width] duration-500 ease-out ' + fillClassName}
                style={{ width: pct + '%' }}
            />
        </div>
    );

    if (!showCount) return bar;
    return (
        <div className="flex items-center gap-3">
            <div className="flex-1">{bar}</div>
            <span className="text-[11px] text-muted tabular-nums whitespace-nowrap">
                {clamped} / {clampedMax}
            </span>
        </div>
    );
}
