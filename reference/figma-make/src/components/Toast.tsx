import { Icon } from "./Icon";

export function Toast({ children }: { children: React.ReactNode }) {
  return (
    <div className="toast">
      <Icon name="close" size={16} />
      {children}
    </div>
  );
}
