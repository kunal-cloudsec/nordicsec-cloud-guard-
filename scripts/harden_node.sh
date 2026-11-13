#!/usr/bin/env bash
set -euo pipefail

# CIS Benchmark Linux Node Hardening for European Cloud Infrastructure
LOG_FILE="/var/log/nordic_hardening.log"

log_info() {
    echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] [INFO] $1" | tee -a "$LOG_FILE"
}

configure_firewall() {
    log_info "Enforcing strict UFW default-deny policies..."
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp comment 'SSH Admin Access'
    ufw allow 443/tcp comment 'HTTPS TLS 1.3 Traffic'
    echo "y" | ufw enable
}

harden_ssh_daemon() {
    log_info "Applying cryptographic SSH hardening..."
    SSHD_CONFIG="/etc/ssh/sshd_config"
    if [[ -f "$SSHD_CONFIG" ]]; then
        sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSHD_CONFIG"
        sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONFIG"
        sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' "$SSHD_CONFIG"
        systemctl reload sshd || true
    fi
}

main() {
    log_info "Starting NordicSec Zero-Trust Node Hardening..."
    configure_firewall
    harden_ssh_daemon
    log_info "Node hardening completed successfully."
}

main "$@"
