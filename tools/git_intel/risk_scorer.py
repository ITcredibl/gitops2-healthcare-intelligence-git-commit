import subprocess
import yaml
import argparse
import json
from dataclasses import dataclass
from pathlib import Path
from typing import List


CONFIG_PATH = Path(__file__).resolve().parents[2] / "config" / "git-forensics-config.yaml"


@dataclass
class Commit:
    sha: str
    message: str
    files: List[str]


class RiskScorer:
    def __init__(self, config_path: Path = CONFIG_PATH):
        with open(config_path, encoding="utf-8") as f:
            self.config = yaml.safe_load(f)

    def get_recent_commits(self, max_count: int = 50) -> List[Commit]:
        cmd = [
            "git",
            "log",
            f"--max-count={max_count}",
            "--pretty=format:%H%x1f%s",
            "--name-only",
        ]
        raw = subprocess.check_output(cmd, text=True)
        lines = raw.splitlines()

        commits: List[Commit] = []
        current: Commit | None = None

        for line in lines:
            if not line:
                continue
            if "\x1f" in line:
                # New commit header
                if current:
                    commits.append(current)
                sha, msg = line.split("\x1f", 1)
                current = Commit(sha=sha, message=msg.strip(), files=[])
            else:
                if current:
                    current.files.append(line.strip())

        if current:
            commits.append(current)
        return commits

    def score_commit(self, commit: Commit) -> float:
        score = 0.0

        # Semantic weight based on type
        semantic_weights = self.config.get("semantic_weights", {})
        ctype = self._extract_type(commit.message)
        score += semantic_weights.get(ctype, 0.1) * 0.5

        # Critical path impact
        critical_paths = self.config.get("critical_paths", {})
        critical_score = 0.0
        for path, meta in critical_paths.items():
            for f in commit.files:
                if f.startswith(path):
                    critical_score = max(
                        critical_score, meta.get("business_criticality", 0.0)
                    )
        score += critical_score * 0.5

        return min(score, 1.0)

    def build_json_report(self, commits: List[Commit]) -> dict:
        report_commits = []
        high = medium = low = 0
        total = 0.0
        for c in commits:
            score = self.score_commit(c)
            if score >= 0.7:
                label = "HIGH"; high += 1
            elif score >= 0.4:
                label = "MEDIUM"; medium += 1
            else:
                label = "LOW"; low += 1
            total += score
            # derive compliance requirements from critical paths (union of domains)
            domains = set()
            for path, meta in (self.config.get("critical_paths", {}) or {}).items():
                if any(f.startswith(path) for f in c.files):
                    for d in meta.get("compliance_domains", []):
                        domains.add(d)
            report_commits.append({
                "sha": c.sha,
                "message": c.message,
                "score": round(score, 4),
                "risk_label": label,
                "files": c.files,
                "compliance_requirements": sorted(list(domains))
            })
        avg = round(total / max(len(commits), 1), 4)
        recommendation = (
            "manual-approval" if avg > 0.8 else
            "canary" if avg > 0.5 else
            "standard"
        )
        return {
            "commits": report_commits,
            "summary": {
                "average_risk_score": avg,
                "risk_distribution": {"high": high, "medium": medium, "low": low},
                "max_score": max([c["score"] for c in report_commits]) if report_commits else 0,
                "deployment_recommendation": recommendation
            }
        }

    @staticmethod
    def _extract_type(message: str) -> str:
        # naive parse of conventional commit type
        if ":" not in message:
            return "other"
        head = message.split(":", 1)[0]
        if "(" in head:
            return head.split("(", 1)[0]
        return head


def main() -> None:
    parser = argparse.ArgumentParser(description="GitOps 2.0 risk scorer")
    parser.add_argument("--max-commits", type=int, default=50, help="Maximum commits to analyze")
    parser.add_argument("--json", action="store_true", help="Output machine-readable JSON summary")
    args = parser.parse_args()

    scorer = RiskScorer()
    commits = scorer.get_recent_commits(max_count=args.max_commits)

    if not commits:
        print("No commits found. Initialize a git repo and create some commits.")
        return

    if args.json:
        report = scorer.build_json_report(commits)
        print(json.dumps(report, indent=2))
        return

    print(f"Analyzing last {len(commits)} commits...\n")
    for c in commits:
        score = scorer.score_commit(c)
        if score >= 0.7:
            label = "HIGH"
        elif score >= 0.4:
            label = "MEDIUM"
        else:
            label = "LOW"
        print(f"[{label}] {score:.2f}  {c.message} ({c.sha[:8]})")


if __name__ == "__main__":
    main()
