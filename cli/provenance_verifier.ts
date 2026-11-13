import * as crypto from "crypto";
import * as fs from "fs";

interface ProvenanceRecord {
  artifactId: string;
  actor: string;
  timestamp: string;
  sha256Digest: string;
  framework: "ISO-27001" | "EU-ANNEX-11";
}

export class SREProvenanceLedger {
  private readonly targetFile: string;

  constructor(targetFile: string) {
    this.targetFile = targetFile;
  }

  public attestArtifact(): ProvenanceRecord {
    const rawBuffer = fs.readFileSync(this.targetFile);
    const hash = crypto.createHash("sha256").update(rawBuffer).digest("hex");

    return {
      artifactId: `urn:nordicsec:sre:${this.targetFile.split("/").pop()}`,
      actor: process.env.GITHUB_ACTOR || "sre-release-bot",
      timestamp: new Date().toISOString(),
      sha256Digest: hash,
      framework: "EU-ANNEX-11",
    };
  }
}

const ledger = new SREProvenanceLedger("terraform/eu_compliant_infra.tf");
console.log(JSON.stringify(ledger.attestArtifact(), null, 2));
