import type { ButtonHTMLAttributes, ReactNode } from "react";

export function PillButton({
  variant = "primary",
  children,
  className = "",
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary" | "secondary" | "text" | "amber";
  children: ReactNode;
}) {
  return (
    <button className={`pill-button ${variant} ${className}`} {...props}>
      {children}
    </button>
  );
}
