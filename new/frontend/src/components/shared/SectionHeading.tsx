interface SectionHeadingProps {
  children: React.ReactNode;
}

export function SectionHeading({ children }: SectionHeadingProps) {
  return (
    <p className="text-[11px] font-semibold uppercase tracking-[0.15em] text-text-secondary">
      {children}
    </p>
  );
}
