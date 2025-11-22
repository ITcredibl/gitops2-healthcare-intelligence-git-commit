# Regression Report Schema

WHY: Document structure of `regression-report.json` produced by `tools/intelligent_bisect.py` to aid developers and auditors in interpreting automated regression detection evidence.

## Top-Level Fields
- service (string): Service label used during bisect run.
- threshold_ms (number): Latency threshold used to flag potential performance regression.
- commit_range (string): Git revision range evaluated (e.g. `HEAD~5..HEAD`).
- total_commits (integer): Count of commits analyzed.
- regression_detected (boolean): True if any commit exceeded latency threshold or failed tests.
- suspected_commits (array): Subset of results flagged as regression candidates.
- results (array): Per-commit evaluation entries.

## Per-Commit Result Object
Each element in `results` and `suspected_commits` contains:
- commit (string): Full SHA.
- status (string): `pass` if test command succeeded, `fail` otherwise.
- latency_ms (number): Execution duration of test command in milliseconds.
- regression (boolean): True if `status=fail` OR `latency_ms > threshold_ms`.

## Usage Guidance
1. CI surfaces a summary; manual inspection may be required for borderline cases.
2. Combine with coverage artifacts to determine if performance regression correlates with new code regions.
3. Suspected commits can be prioritized for profiling or rollback planning.

## Future Extensions
- percentiles: Capture p95/p99 latency during repeated test runs.
- memory_profile: Include memory usage metrics to detect leaks.
- external_metrics: Link to APM traces or dashboards.
- remediation_suggestions: AI-generated hints for fixing regressions.

## Example
```json
{
  "service": "payment-gateway",
  "threshold_ms": 200.0,
  "commit_range": "HEAD~5..HEAD",
  "total_commits": 6,
  "regression_detected": true,
  "suspected_commits": [
    {"commit": "abc123...", "status": "pass", "latency_ms": 245.91, "regression": true}
  ],
  "results": [ /* all commit entries */ ]
}
```
