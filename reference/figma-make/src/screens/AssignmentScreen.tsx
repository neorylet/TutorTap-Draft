import { useState } from "react";
import { AppBar } from "../components/AppBar";
import { FormField } from "../components/FormField";
import { Icon } from "../components/Icon";
import { LottieSlot } from "../components/LottieSlot";
import { PillButton } from "../components/PillButton";
import { ProgressBar } from "../components/ProgressBar";
import { Toast } from "../components/Toast";

export function AssignmentScreen() {
  const [state, setState] = useState<"form" | "uploading" | "submitted">("form");
  if (state === "uploading")
    return (
      <div className="screen centered-flow">
        <AppBar title="Submit assignment" />
        <LottieSlot file="uploading_cloud.json" size={96} compact />
        <h2>Uploading your work</h2>
        <ProgressBar value={68} label="Linear_Equations.pdf" />
        <PillButton onClick={() => setState("submitted")}>Finish upload</PillButton>
      </div>
    );
  return (
    <div className="screen">
      <AppBar title="Homework 1" />
      {state === "submitted" && <Toast>Submitted successfully</Toast>}
      <div className="card assignment-brief">
        <small>Due Dec 22 · 11:59 PM</small>
        <h2>Linear Equations</h2>
        <p>Solve the five equations and show each step. Attach a PDF or write your answer below.</p>
      </div>
      <FormField label="Your answer" placeholder="Write your solution steps" textarea />
      <button className="upload-button" onClick={() => setState("uploading")}>
        <Icon name="upload" /> Attach a file <small>PDF, DOCX up to 10 MB</small>
      </button>
      <PillButton onClick={() => setState("submitted")}>Submit assignment</PillButton>
    </div>
  );
}
