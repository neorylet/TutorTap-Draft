import { useEffect, useState } from "react";
import { FilterChip } from "../components/FilterChip";
import { FormField } from "../components/FormField";
import { Icon } from "../components/Icon";
import { LottieSlot } from "../components/LottieSlot";
import { PillButton } from "../components/PillButton";
import { ProgressBar } from "../components/ProgressBar";
import { StatusBadge } from "../components/StatusBadge";
import { useAppState } from "../state/AppState";

export function TutorProfileVerification() {
  const { demo, setRole, go } = useAppState();
  const [upload, setUpload] = useState<"idle" | "uploading" | "failed">(
    demo === "upload-failed" ? "failed" : demo === "uploading" ? "uploading" : "idle",
  );
  useEffect(() => {
    if (demo === "upload-failed") setUpload("failed");
    if (demo === "uploading") setUpload("uploading");
  }, [demo]);
  return (
    <div className="screen tab-screen">
      <h1>Profile & verification</h1>
      <p className="muted">Keep your public tutor profile current.</p>
      <div className="avatar-upload">
        <span className="avatar large">AR</span>
        <button>
          <Icon name="upload" size={16} /> Change avatar
        </button>
      </div>
      <FormField label="Hourly rate" placeholder="₱450" />
      <div className="form-field">
        <span>Subjects</span>
        <div className="chip-row">
          <FilterChip label="Math" active />
          <FilterChip label="Computer Science" />
          <FilterChip label="English" />
        </div>
      </div>
      <FormField
        label="Bio"
        value="I help students build confidence in algebra and calculus through clear worked examples."
        textarea
      />
      <FormField
        label="Online meeting link / room details"
        value="meet.tutortap.app/ana-math-2014"
        helper="This appears only on confirmed bookings."
      />
      <section>
        <h2>Verification documents</h2>
        <div className="card document-list">
          <div>
            <Icon name="file" />
            <span>
              <strong>Degree certificate</strong>
              <small>degree_ana.pdf</small>
            </span>
            <StatusBadge status="verified" />
          </div>
          <div>
            <Icon name="file" />
            <span>
              <strong>Professional ID</strong>
              <small>let_id.pdf</small>
            </span>
            <StatusBadge status="pending" />
          </div>
          <div>
            <Icon name="file" />
            <span>
              <strong>Proof of experience</strong>
              <small>Needs a clearer scan</small>
            </span>
            <StatusBadge status="rejected" />
          </div>
        </div>
        {upload === "idle" && (
          <button className="upload-button" onClick={() => setUpload("uploading")}>
            <Icon name="upload" /> Upload document
          </button>
        )}
        {upload === "uploading" && (
          <div className="upload-state">
            <LottieSlot file="uploading_cloud.json" size={96} compact />
            <div>
              <strong>Uploading teaching_certificate.pdf</strong>
              <ProgressBar value={64} />
              <button onClick={() => setUpload("failed")}>Cancel</button>
            </div>
          </div>
        )}
        {upload === "failed" && (
          <div className="upload-failed">
            <Icon name="close" />
            <div>
              <strong>Upload failed — file too large (max 10 MB)</strong>
              <small>Compress the file or choose another document.</small>
            </div>
            <button onClick={() => setUpload("uploading")}>Retry</button>
          </div>
        )}
      </section>
      <PillButton>Save profile</PillButton>
      <div className="profile-actions">
        <button
          onClick={() => {
            setRole("student");
            go("student-home");
          }}
        >
          Switch role (demo)
        </button>
        <button onClick={() => go("auth")}>Sign out</button>
      </div>
    </div>
  );
}
