import { useState } from "react";
import { Icon } from "./Icon";

export function FormField({
  label,
  placeholder,
  helper,
  error,
  textarea,
  type = "text",
  value,
  onChange,
}: {
  label: string;
  placeholder?: string;
  helper?: string;
  error?: string;
  textarea?: boolean;
  type?: string;
  value?: string;
  onChange?: (value: string) => void;
}) {
  const [show, setShow] = useState(false);
  return (
    <label className="form-field">
      <span>{label}</span>
      <div className={error ? "field-control error" : "field-control"}>
        {textarea ? (
          <textarea
            placeholder={placeholder}
            value={value}
            onChange={(e) => onChange?.(e.target.value)}
          />
        ) : (
          <input
            type={type === "password" && show ? "text" : type}
            placeholder={placeholder}
            value={value}
            onChange={(e) => onChange?.(e.target.value)}
          />
        )}
        {type === "password" && (
          <button type="button" onClick={() => setShow(!show)} aria-label="Show password">
            <Icon name="eye" size={18} />
          </button>
        )}
      </div>
      {error && <small className="error-text">{error}</small>}
      {helper && <small>{helper}</small>}
    </label>
  );
}
