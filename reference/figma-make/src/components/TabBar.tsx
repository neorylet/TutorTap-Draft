import type { Screen } from "../state/AppState";
import { useAppState } from "../state/AppState";
import { Icon, type IconName } from "./Icon";

const student: { label: string; icon: IconName; screen: Screen }[] = [
  { label: "Home", icon: "home", screen: "student-home" },
  { label: "Browse", icon: "search", screen: "browse" },
  { label: "Bookings", icon: "calendar", screen: "bookings" },
  { label: "Classroom", icon: "book", screen: "student-classroom" },
  { label: "Study", icon: "spark", screen: "study" },
];
const tutor: { label: string; icon: IconName; screen: Screen }[] = [
  { label: "Dashboard", icon: "home", screen: "tutor-dashboard" },
  { label: "Students", icon: "users", screen: "tutor-students" },
  { label: "Classroom", icon: "book", screen: "tutor-classroom" },
  { label: "Earnings", icon: "wallet", screen: "tutor-earnings" },
  { label: "Profile", icon: "user", screen: "tutor-profile-settings" },
];

export function TabBar() {
  const { role, screen, go } = useAppState();
  const items = role === "student" ? student : tutor;
  return (
    <nav className="tab-bar">
      {items.map((item) => (
        <button
          key={item.label}
          className={screen === item.screen ? "active" : ""}
          onClick={() => go(item.screen)}
        >
          <Icon name={item.icon} size={20} />
          <span>{item.label}</span>
        </button>
      ))}
    </nav>
  );
}
