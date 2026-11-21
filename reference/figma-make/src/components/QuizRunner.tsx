import { useState } from "react";
import { quizQuestions } from "../data/sampleData";
import { useAppState } from "../state/AppState";
import { PillButton } from "./PillButton";
import { ProgressBar } from "./ProgressBar";

export function QuizRunner() {
  const { back } = useAppState();
  const [index, setIndex] = useState(0);
  const [selected, setSelected] = useState<number | null>(null);
  const [answers, setAnswers] = useState<number[]>([]);
  const [done, setDone] = useState(false);
  const question = quizQuestions[index];
  if (done)
    return (
      <div className="screen quiz-screen">
        <div className="score-ring">
          <strong>8/10</strong>
          <span>80%</span>
        </div>
        <h1 className="center-title">Strong work on functions</h1>
        <p className="muted centered">Review the two concepts that need another look.</p>
        <div className="card review-list">
          {quizQuestions.map((q, i) => (
            <div key={q.prompt}>
              <span>{i + 1}</span>
              <p>{q.prompt}</p>
              <strong className={i === 1 ? "wrong" : ""}>{i === 1 ? "Review" : "Correct"}</strong>
            </div>
          ))}
        </div>
        <div className="button-pair">
          <PillButton
            variant="secondary"
            onClick={() => {
              setIndex(0);
              setAnswers([]);
              setDone(false);
            }}
          >
            Retake
          </PillButton>
          <PillButton onClick={back}>Done</PillButton>
        </div>
      </div>
    );
  return (
    <div className="screen quiz-screen">
      <div className="quiz-top">
        <div>
          <small>
            Question {index + 1} of {quizQuestions.length}
          </small>
          <ProgressBar value={((index + 1) / quizQuestions.length) * 100} />
        </div>
        <span className="timer">14:32</span>
      </div>
      <h1>{question.prompt}</h1>
      <div className="choices">
        {question.choices.map((choice, i) => (
          <button
            key={choice}
            className={selected === i ? "selected" : ""}
            onClick={() => setSelected(i)}
          >
            <span>{String.fromCharCode(65 + i)}</span>
            {choice}
          </button>
        ))}
      </div>
      <PillButton
        disabled={selected === null}
        onClick={() => {
          const next = [...answers, selected!];
          setAnswers(next);
          setSelected(null);
          if (index === quizQuestions.length - 1) setDone(true);
          else setIndex(index + 1);
        }}
      >
        {index === quizQuestions.length - 1 ? "Finish exam" : "Next question"}
      </PillButton>
    </div>
  );
}
