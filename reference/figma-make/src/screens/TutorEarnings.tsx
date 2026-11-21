export function TutorEarnings() {
  const rows = [
    ["Dec 20", "Mika Santos", "₱450", "₱54", "₱396"],
    ["Dec 18", "Rafael Uy", "₱450", "₱54", "₱396"],
    ["Dec 16", "Joaquin Perez", "₱600", "₱72", "₱528"],
  ];
  return (
    <div className="screen tab-screen">
      <h1>Earnings</h1>
      <p className="muted">Clear payouts from completed online sessions.</p>
      <div className="earnings-total">
        <small>DECEMBER PAYOUT</small>
        <strong>₱8,640</strong>
        <span>18 completed sessions</span>
      </div>
      <div className="earnings-head">
        <span>Booking</span>
        <span>Subtotal</span>
        <span>Fee</span>
        <span>Payout</span>
      </div>
      <div className="card earnings-list">
        {rows.map((row) => (
          <div key={row[0] + row[1]}>
            <span>
              <strong>{row[1]}</strong>
              <small>{row[0]}</small>
            </span>
            <span>{row[2]}</span>
            <span>{row[3]}</span>
            <strong>{row[4]}</strong>
          </div>
        ))}
      </div>
      <div className="commission-note">
        TutorTap commission is 12% of each completed session subtotal.
      </div>
    </div>
  );
}
