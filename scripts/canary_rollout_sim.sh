#!/usr/bin/env bash
set -euo pipefail
# Canary rollout simulation for payment-gateway.
# WHY: Demonstrates risk-adaptive staged deployment for GitOps 2.0.
# Enhancements: multi-probe health checks with retry/backoff, configurable timing, explicit rollback.

SERVICE=${SERVICE:-payment-gateway}
PORT=${PORT:-8080}
IMAGE=${IMAGE:-gitops2-demo/$SERVICE:local}
# Sleep per stage (seconds). Override via STAGE_SLEEP env.
STAGE_SLEEP=${STAGE_SLEEP:-2}
# Number of health probes per stage.
PROBES=${PROBES:-3}
# Interval between probes.
PROBE_INTERVAL=${PROBE_INTERVAL:-1}
# Optional risk score to dynamically increase probes (higher risk => more probes)
RISK_SCORE=${RISK_SCORE:-0.0}
if (( $(echo "$RISK_SCORE > 0.8" | bc -l) )); then
  PROBES=${PROBES_HIGH_RISK:-5}
fi

stages=(5 25 100)

rollback() {
  local pct=$1
  echo "[canary] Rollback initiated at ${pct}% stage (pointer to previous stable release)"
  # Placeholder for real rollback actions (traffic shift, scale down new revision, alerting)
  exit 1
}

simulate_health() {
  # Placeholder: would query real metrics & error rate.
  curl -sf "http://localhost:${PORT}/health" >/dev/null || return 1
  return 0
}

for pct in "${stages[@]}"; do
  echo "[canary] Deploying stage: ${pct}% traffic"
  sleep "${STAGE_SLEEP}"

  # Multi-probe health verification
  healthy=false
  for ((i=1; i<=PROBES; i++)); do
    if simulate_health; then
      healthy=true
      echo "[canary] Probe ${i}/${PROBES} succeeded"
      break
    else
      echo "[canary] Probe ${i}/${PROBES} failed; retrying in ${PROBE_INTERVAL}s"
      sleep "${PROBE_INTERVAL}"
    fi
  done

  if [[ ${healthy} == false ]]; then
    echo "[canary] Health check failed at ${pct}% - initiating rollback"
    rollback "${pct}"
  fi

  echo "[canary] Stage ${pct}% healthy"

done

echo "[canary] Rollout complete"
