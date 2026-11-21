import { useState } from "react";
import { AppBar } from "../components/AppBar";
import { FormField } from "../components/FormField";
import { PillButton } from "../components/PillButton";
import { SegmentedControl } from "../components/SegmentedControl";
import { useAppState } from "../state/AppState";

export function AuthScreen() {
  const [mode, setMode] = useState("Sign in");
  const { go } = useAppState();
  return (
    <div className="screen">
      <AppBar title="Welcome to TutorTap" />
      <div className="auth-mark">
        T<span>T</span>
      </div>
      <h2 className="section-title">
        {mode === "Sign in" ? "Continue your learning" : "Create your account"}
      </h2>
      <SegmentedControl items={["Sign in", "Create account"]} value={mode} onChange={setMode} />
      <div className="form-stack">
        <FormField
          label="Email"
          placeholder="mika@email.com"
          error="Enter a valid email address."
        />
        <FormField label="Password" placeholder="At least 8 characters" type="password" />
      </div>
      <button className="text-link">Forgot password?</button>
      <PillButton onClick={() => go("role-select")}>{mode}</PillButton>
      <div className="divider">
        <span>or</span>
      </div>
      <PillButton variant="secondary" onClick={() => go("role-select")}>
        <b className="google-mark">G</b> Continue with Google
      </PillButton>
    </div>
  );
}
