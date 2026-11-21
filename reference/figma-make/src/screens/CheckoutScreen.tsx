import { AppBar } from "../components/AppBar";
import { FormField } from "../components/FormField";
import { PillButton } from "../components/PillButton";
import { StatusBadge } from "../components/StatusBadge";
import { useAppState } from "../state/AppState";

export function CheckoutScreen() {
  const { go } = useAppState();
  return (
    <div className="screen">
      <AppBar title="Checkout" />
      <div className="card summary-card">
        <span className="avatar">AR</span>
        <div>
          <strong>Ana Reyes · Math</strong>
          <p>Sat, Dec 20 · 2:00–3:00 PM · Online</p>
        </div>
      </div>
      <div className="form-stack">
        <FormField label="Full name" placeholder="Mika Santos" />
        <FormField label="Email" placeholder="mika@email.com" />
        <FormField
          label="Note to tutor (optional)"
          placeholder="Topics you want to focus on"
          textarea
        />
      </div>
      <label className="check-row">
        <input type="checkbox" defaultChecked />
        <span>I agree to the cancellation policy</span>
      </label>
      <StatusBadge status="Simulated payment — no real charge" />
      <div className="card price-card">
        <div>
          <span>Session subtotal</span>
          <strong>₱450.00</strong>
        </div>
        <div>
          <span>Platform commission (12%)</span>
          <strong>₱54.00</strong>
        </div>
        <hr />
        <div className="total">
          <span>Total charged</span>
          <strong>₱450.00</strong>
        </div>
        <div>
          <span>Tutor payout</span>
          <strong>₱396.00</strong>
        </div>
        <small>Commission is deducted from the tutor's payout.</small>
      </div>
      <PillButton onClick={() => go("confirmation")}>Confirm booking</PillButton>
    </div>
  );
}
