export type IconName =
  | "home"
  | "search"
  | "calendar"
  | "book"
  | "spark"
  | "users"
  | "wallet"
  | "user"
  | "back"
  | "chevron"
  | "check"
  | "copy"
  | "video"
  | "clock"
  | "file"
  | "download"
  | "upload"
  | "play"
  | "grid"
  | "list"
  | "eye"
  | "plus"
  | "close"
  | "message"
  | "star";

const paths: Record<IconName, React.ReactNode> = {
  home: (
    <>
      <path d="m3 10 9-7 9 7" />
      <path d="M5 9v11h14V9M9 20v-6h6v6" />
    </>
  ),
  search: (
    <>
      <circle cx="11" cy="11" r="7" />
      <path d="m20 20-4-4" />
    </>
  ),
  calendar: (
    <>
      <rect x="3" y="5" width="18" height="16" rx="2" />
      <path d="M8 3v4M16 3v4M3 10h18" />
    </>
  ),
  book: (
    <>
      <path d="M4 5a3 3 0 0 1 3-2h5v18H7a3 3 0 0 0-3 2Z" />
      <path d="M20 5a3 3 0 0 0-3-2h-5v18h5a3 3 0 0 1 3 2Z" />
    </>
  ),
  spark: (
    <>
      <path d="m12 3 1.5 4.5L18 9l-4.5 1.5L12 15l-1.5-4.5L6 9l4.5-1.5Z" />
      <path d="m19 15 .8 2.2L22 18l-2.2.8L19 21l-.8-2.2L16 18l2.2-.8Z" />
    </>
  ),
  users: (
    <>
      <circle cx="9" cy="8" r="3" />
      <path d="M3 20c0-4 2-6 6-6s6 2 6 6" />
      <circle cx="17" cy="9" r="2.5" />
      <path d="M16 15c3.3 0 5 1.7 5 5" />
    </>
  ),
  wallet: (
    <>
      <path d="M4 6h15a2 2 0 0 1 2 2v11H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h13" />
      <path d="M16 11h5v5h-5a2.5 2.5 0 0 1 0-5Z" />
    </>
  ),
  user: (
    <>
      <circle cx="12" cy="8" r="4" />
      <path d="M4 21c.5-5 3-7 8-7s7.5 2 8 7" />
    </>
  ),
  back: (
    <>
      <path d="m15 18-6-6 6-6" />
    </>
  ),
  chevron: <path d="m9 18 6-6-6-6" />,
  check: <path d="m5 12 4 4L19 6" />,
  copy: (
    <>
      <rect x="8" y="8" width="12" height="12" rx="2" />
      <path d="M16 8V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h3" />
    </>
  ),
  video: (
    <>
      <rect x="3" y="6" width="13" height="12" rx="2" />
      <path d="m16 10 5-3v10l-5-3" />
    </>
  ),
  clock: (
    <>
      <circle cx="12" cy="12" r="9" />
      <path d="M12 7v5l3 2" />
    </>
  ),
  file: (
    <>
      <path d="M6 3h8l4 4v14H6Z" />
      <path d="M14 3v5h5" />
    </>
  ),
  download: (
    <>
      <path d="M12 3v12m-4-4 4 4 4-4" />
      <path d="M4 19h16" />
    </>
  ),
  upload: (
    <>
      <path d="M12 17V5m-4 4 4-4 4 4" />
      <path d="M4 19h16" />
    </>
  ),
  play: <path d="m9 7 8 5-8 5Z" />,
  grid: (
    <>
      <rect x="4" y="4" width="6" height="6" rx="1" />
      <rect x="14" y="4" width="6" height="6" rx="1" />
      <rect x="4" y="14" width="6" height="6" rx="1" />
      <rect x="14" y="14" width="6" height="6" rx="1" />
    </>
  ),
  list: (
    <>
      <path d="M9 6h11M9 12h11M9 18h11" />
      <circle cx="4" cy="6" r="1" />
      <circle cx="4" cy="12" r="1" />
      <circle cx="4" cy="18" r="1" />
    </>
  ),
  eye: (
    <>
      <path d="M2 12s3-6 10-6 10 6 10 6-3 6-10 6S2 12 2 12Z" />
      <circle cx="12" cy="12" r="2.5" />
    </>
  ),
  plus: <path d="M12 5v14M5 12h14" />,
  close: <path d="m6 6 12 12M18 6 6 18" />,
  message: <path d="M4 4h16v13H8l-4 4Z" />,
  star: <path d="m12 3 2.7 5.5 6.1.9-4.4 4.3 1 6.1-5.4-2.9-5.4 2.9 1-6.1-4.4-4.3 6.1-.9Z" />,
};

export function Icon({
  name,
  size = 20,
  className = "",
}: {
  name: IconName;
  size?: number;
  className?: string;
}) {
  return (
    <svg
      aria-hidden="true"
      className={className}
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      {paths[name]}
    </svg>
  );
}
