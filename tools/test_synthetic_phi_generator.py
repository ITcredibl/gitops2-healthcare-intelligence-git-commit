#!/usr/bin/env python3
import json, subprocess, sys, re

# Basic tests for synthetic_phi_generator

def run(cmd: str) -> str:
    p = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if p.returncode != 0:
        print(err.decode(), file=sys.stderr)
        raise SystemExit(p.returncode)
    return out.decode()

def test_json_output():
    out = run("python3 tools/synthetic_phi_generator.py --count 3 --json")
    data = json.loads(out)
    assert len(data) == 3
    for rec in data:
        assert rec["anonymized"] is True
        assert set(["name","dob","diagnosis_codes"]).issubset(set(rec["phi_fields"]))
        assert re.match(r"REC-[A-Z0-9]{8}", rec["record_id"]) is not None
        assert re.match(r"PAT-[A-Z0-9]{8}", rec["patient_ref"]) is not None

if __name__ == "__main__":
    test_json_output()
    print("synthetic_phi_generator tests passed")
