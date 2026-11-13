terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.10"
    }
  }
}

variable "environment" {
  type    = string
  default = "copenhagen-prod"
}

variable "region" {
  type    = string
  default = "europe-north1"
}

resource "google_kms_key_ring" "sre_audit_keyring" {
  name     = "${var.environment}-sre-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "vault_key" {
  name            = "${var.environment}-vault-key"
  key_ring        = google_kms_key_ring.sre_audit_keyring.id
  rotation_period = "7776000s"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket" "regulated_eu_vault" {
  name                        = "${var.environment}-sre-audit-vault"
  location                    = "EU"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.vault_key.id
  }

  retention_policy {
    is_locked        = true
    retention_period = 31536000
  }
}

output "vault_endpoint" {
  value       = google_storage_bucket.regulated_eu_vault.url
  description = "Immutable EU SRE storage endpoint"
}
