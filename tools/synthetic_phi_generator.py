#!/usr/bin/env python3
"""Synthetic PHI Data Generator (demo)
WHY: Provide anonymized, non-realistic patient-like records for testing compliance flows
without exposing actual protected health information. Ensures developers can exercise
HIPAA-related code paths safely.
"""
from __future__ import annotations
import argparse, json, random, string, time
from dataclasses import dataclass, asdict
from typing import List

FIRST_NAMES = ["Alex","Jordan","Taylor","Casey","Riley","Morgan","Jamie","Quinn","Avery","Peyton"]
LAST_NAMES = ["Smith","Johnson","Lee","Brown","Garcia","Martinez","Davis","Miller","Wilson","Anderson"]
DIAG_CODES = ["E11.9","I10","J45.909","M54.5","F32.9","K21.9","N39.0","R51","Z00.00","Z71.3"]
DEVICE_IDS = ["DEV-INSULIN-PUMP","DEV-CARDIO-MON","DEV-ORTHO-TRACK","DEV-DERM-SCAN"]

@dataclass
class SyntheticPHIRecord:
    record_id: str
    patient_ref: str
    name: str
    dob: str
    diagnosis_codes: List[str]
    device_id: str | None
    created_ts: int
    phi_fields: List[str]
    anonymized: bool
    risk_tags: List[str]

def _rand_id(prefix: str) -> str:
    return f"{prefix}-" + ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))

def _random_date() -> str:
    # Return YYYY-01-15 style deterministic month/day for simplicity
    year = random.randint(1970, 2005)
    return f"{year}-01-15"

def generate_record(high_risk: bool=False) -> SyntheticPHIRecord:
    fn = random.choice(FIRST_NAMES)
    ln = random.choice(LAST_NAMES)
    codes = random.sample(DIAG_CODES, k=random.randint(1,3))
    device = random.choice(DEVICE_IDS) if random.random() < 0.3 else None
    phi = ["name","dob","diagnosis_codes"]
    risk = ["phi"]
    if high_risk:
        risk.append("high-rarity-diagnosis")
    return SyntheticPHIRecord(
        record_id=_rand_id("REC"),
        patient_ref=_rand_id("PAT"),
        name=f"{fn} {ln}",
        dob=_random_date(),
        diagnosis_codes=codes,
        device_id=device,
        created_ts=int(time.time()),
        phi_fields=phi,
        anonymized=True,
        risk_tags=risk,
    )

def generate(n: int, high_risk_ratio: float) -> List[SyntheticPHIRecord]:
    records = []
    for i in range(n):
        hr = random.random() < high_risk_ratio
        records.append(generate_record(hr))
    return records

def main():
    p = argparse.ArgumentParser(description="Generate synthetic PHI records for testing")
    p.add_argument("--count", type=int, default=5)
    p.add_argument("--high-risk-ratio", type=float, default=0.2)
    p.add_argument("--json", action="store_true")
    args = p.parse_args()

    records = generate(args.count, args.high_risk_ratio)
    out = [asdict(r) for r in records]
    if args.json:
        print(json.dumps(out, indent=2))
    else:
        for r in out:
            print(r)

if __name__ == "__main__":
    main()
