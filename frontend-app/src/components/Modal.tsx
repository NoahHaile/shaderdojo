import * as Dialog from '@radix-ui/react-dialog';
import type { ReactNode } from 'react';

interface Props {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    title?: string;
    description?: string;
    children?: ReactNode;
    footer?: ReactNode;
}

export function Modal({ open, onOpenChange, title, description, children, footer }: Props) {
    return (
        <Dialog.Root open={open} onOpenChange={onOpenChange}>
            <Dialog.Portal>
                <Dialog.Overlay className="fixed inset-0 bg-black/40 backdrop-blur-[1px] z-40
                                          data-[state=open]:animate-in data-[state=open]:fade-in" />
                <Dialog.Content
                    className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 z-50
                               w-[min(480px,92vw)] bg-white border border-muted/30 rounded-xl
                               shadow-xl p-6 outline-none">
                    {title && <Dialog.Title className="text-lg font-semibold text-ink mb-1">{title}</Dialog.Title>}
                    {description && (
                        <Dialog.Description className="text-sm text-ink/70 mb-4">
                            {description}
                        </Dialog.Description>
                    )}
                    {children}
                    {footer && <div className="mt-5 flex justify-end gap-2">{footer}</div>}
                </Dialog.Content>
            </Dialog.Portal>
        </Dialog.Root>
    );
}
