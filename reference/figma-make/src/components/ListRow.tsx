import { Icon } from "./Icon";

export function ListRow({
  icon = "file",
  title,
  meta,
  tag,
  action,
  onClick,
}: {
  icon?: "file" | "book" | "calendar";
  title: string;
  meta?: string;
  tag?: string;
  action?: React.ReactNode;
  onClick?: () => void;
}) {
  return (
    <div
      className="list-row"
      role={onClick ? "button" : undefined}
      tabIndex={onClick ? 0 : undefined}
      onClick={onClick}
      onKeyDown={(event) => {
        if (onClick && (event.key === "Enter" || event.key === " ")) onClick();
      }}
    >
      <span className="row-icon">
        <Icon name={icon} />
      </span>
      <span className="row-copy">
        <strong>{title}</strong>
        {meta && <small>{meta}</small>}
        {tag && <em>{tag}</em>}
      </span>
      {action ?? <Icon name="chevron" size={18} />}
    </div>
  );
}
