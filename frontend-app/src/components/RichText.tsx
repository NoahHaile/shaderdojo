import DOMPurify from 'dompurify';
import { useMemo } from 'react';

interface Props {
    /** Author-supplied HTML. Sanitized before render. */
    html: string;
    className?: string;
}

/**
 * Renders lesson descriptions (or any author-authored HTML) safely.
 * Sanitizes via DOMPurify with a small allowlist: paragraphs, headings,
 * inline formatting, lists, links, images, code blocks.
 */
export function RichText({ html, className }: Props) {
    const sanitized = useMemo(() => DOMPurify.sanitize(html, {
        ALLOWED_TAGS: [
            'p', 'br', 'hr',
            'h1', 'h2', 'h3', 'h4',
            'strong', 'em', 'b', 'i', 'u', 'code', 'pre', 'kbd', 'mark',
            'ul', 'ol', 'li',
            'a', 'img',
            'blockquote',
            'span', 'div',
        ],
        ALLOWED_ATTR: ['href', 'target', 'rel', 'src', 'alt', 'title', 'class'],
        ALLOW_DATA_ATTR: false,
    }), [html]);

    return (
        <div
            className={'lesson-prose ' + (className ?? '')}
            dangerouslySetInnerHTML={{ __html: sanitized }}
        />
    );
}
