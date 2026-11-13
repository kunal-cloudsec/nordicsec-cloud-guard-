import re
import sys
import json
from pathlib import Path
from datetime import datetime, timezone


class SREComplianceAuditor:
    def __init__(self, tf_path: str):
        self.tf_path = Path(tf_path)
        self.findings = []

    def run_audit(self) -> dict:
        if not self.tf_path.exists():
            sys.exit(f"[FATAL] Target manifest missing: {self.tf_path}")

        content = self.tf_path.read_text(encoding="utf-8")

        controls = [
            (
                "ISO-27001-AC-01",
                r'public_access_prevention\s*=\s*"enforced"',
                "Public access prevention must be strictly enforced.",
            ),
            (
                "ISO-27001-AC-02",
                r"uniform_bucket_level_access\s*=\s*true",
                "Uniform bucket-level access control is mandatory.",
            ),
            (
                "EU-ANNEX11-LOG-04",
                r"is_locked\s*=\s*true",
                "Immutable retention lock must be active for SRE audit logs.",
            ),
            (
                "ISO-27001-CRY-09",
                r'rotation_period\s*=\s*"7776000s"',
                "KMS cryptographic key rotation must not exceed 90 days.",
            ),
        ]

        for control_id, pattern, detail in controls:
            passed = bool(re.search(pattern, content))
            self.findings.append({
                "control": control_id,
                "status": "PASS" if passed else "FAIL",
                "detail": detail,
            })

        return {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "target": str(self.tf_path),
            "slo_compliant": all(item["status"] == "PASS" for item in self.findings),
            "results": self.findings,
        }


if __name__ == "__main__":
    auditor = SREComplianceAuditor("terraform/eu_compliant_infra.tf")
    report = auditor.run_audit()
    print(json.dumps(report, indent=2))
    if not report["slo_compliant"]:
        sys.exit(1)
      
