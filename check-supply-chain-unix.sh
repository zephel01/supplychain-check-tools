#!/bin/bash

################################################################################
# Supply Chain Security Check Tool - macOS / Linux
# サプライチェーン攻撃防止 ローカル環境チェックツール
################################################################################

set -o pipefail

# Configuration
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="supply_chain_check_report_${TIMESTAMP}.txt"
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNED=0
CHECKS_INFO=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*) OS_TYPE="macOS" ;;
        Linux*) OS_TYPE="Linux" ;;
        *) OS_TYPE="Unknown" ;;
    esac
}

# ============================================================================
# Utility Functions
# ============================================================================

write_log() {
    echo "$1" >> "$REPORT_FILE"
}

write_header() {
    local header="$1"
    local separator="================================================================================"
    echo -e "\n${CYAN}${separator}${NC}"
    echo -e "${CYAN}► ${header}${NC}"
    echo -e "${CYAN}${separator}${NC}\n"
    
    write_log ""
    write_log "$separator"
    write_log "► $header"
    write_log "$separator"
    write_log ""
}

pass_check() {
    local message="$1"
    echo -e "${GREEN}✓ PASS${NC}: $message"
    write_log "✓ PASS: $message"
    ((CHECKS_PASSED++))
}

fail_check() {
    local message="$1"
    echo -e "${RED}✗ FAIL${NC}: $message"
    write_log "✗ FAIL: $message"
    ((CHECKS_FAILED++))
}

warn_check() {
    local message="$1"
    echo -e "${YELLOW}⚠ WARN${NC}: $message"
    write_log "⚠ WARN: $message"
    ((CHECKS_WARNED++))
}

info_check() {
    local message="$1"
    echo -e "${BLUE}ℹ INFO${NC}: $message"
    write_log "ℹ INFO: $message"
    ((CHECKS_INFO++))
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# 1. Code Signature Verification
# ============================================================================

check_code_signatures() {
    write_header "1. コード署名検証"
    
    if [ "$OS_TYPE" == "macOS" ]; then
        # macOS codesign verification
        local app_paths=(
            "/Applications"
            "/System/Applications"
            "/usr/local/bin"
        )
        
        local verified_count=0
        local failed_count=0
        
        for path in "${app_paths[@]}"; do
            if [ -d "$path" ]; then
                while IFS= read -r -d '' app; do
                    if codesign -v "$app" &>/dev/null 2>&1; then
                        ((verified_count++))
                    else
                        ((failed_count++))
                    fi
                done < <(find "$path" -maxdepth 2 -type f \( -name "*.app" -o -name "*.dylib" \) -print0 2>/dev/null | head -z -20)
            fi
        done
        
        if [ $verified_count -gt 0 ]; then
            pass_check "Found $verified_count signed binaries"
        fi
        
        if [ $failed_count -eq 0 ]; then
            pass_check "No unsigned system binaries detected in sampled paths"
        else
            warn_check "Found $failed_count unsigned binaries (sampling)"
        fi
        
        # Notarization check for macOS
        if check_command spctl; then
            info_check "macOS Gatekeeper is available"
        fi
        
    else
        # Linux - check file permissions and ownership
        info_check "Checking critical system binaries..."
        
        local suspicious_perms=0
        for binary in /usr/bin/* /usr/local/bin/*; do
            if [ -f "$binary" ]; then
                local perms=$(stat -L -c %a "$binary" 2>/dev/null || stat -L -f %OLp "$binary" 2>/dev/null)
                # Check for unusual SUID/SGID bits
                if [[ "$perms" =~ [2-7][0-9]{3} ]]; then
                    ((suspicious_perms++))
                fi
            fi
        done
        
        if [ $suspicious_perms -lt 10 ]; then
            pass_check "System binaries have appropriate permissions"
        else
            warn_check "Found $suspicious_perms files with unusual SUID/SGID bits"
        fi
    fi
}

# ============================================================================
# 2. GnuPG Signature Verification
# ============================================================================

check_gpg_signatures() {
    write_header "2. GnuPG 署名検証"
    
    if ! check_command gpg; then
        info_check "GnuPG not installed, skipping"
        return
    fi
    
    info_check "GnuPG version: $(gpg --version | head -1)"
    
    # Check GPG key list
    local gpg_keys=$(gpg --list-keys 2>/dev/null | grep -c "pub" || echo "0")
    info_check "GPG public keys installed: $gpg_keys"
    
    # Check for trusted keys
    if [ "$gpg_keys" -gt 0 ]; then
        pass_check "GPG keyring is configured"
    else
        warn_check "No GPG keys installed"
    fi
}

# ============================================================================
# 3. npm Packages
# ============================================================================

check_npm_packages() {
    write_header "3. npm パッケージ検証"
    
    if ! check_command npm; then
        info_check "npm not installed, skipping"
        return
    fi
    
    info_check "npm version: $(npm --version)"
    
    # Find package-lock.json files
    local lock_files=$(find "$HOME" -name "package-lock.json" -type f 2>/dev/null | wc -l)
    
    if [ "$lock_files" -gt 0 ]; then
        pass_check "Found $lock_files package-lock.json files"
    else
        warn_check "No package-lock.json files found"
    fi
    
    # Check npm audit in current directory if package.json exists
    if [ -f "package.json" ]; then
        info_check "Running npm audit in current directory..."
        if npm audit --audit-level=moderate --json 2>/dev/null | grep -q '"vulnerabilities"'; then
            local vuln_count=$(npm audit --json 2>/dev/null | grep -o '"total":[0-9]*' | head -1 | grep -o '[0-9]*')
            if [ "$vuln_count" == "0" ]; then
                pass_check "npm audit: No vulnerabilities detected"
            else
                fail_check "npm audit: Found $vuln_count vulnerabilities"
            fi
        fi
    fi
}

# ============================================================================
# 4. Python Packages
# ============================================================================

check_python_packages() {
    write_header "4. Python パッケージ検証"
    
    if ! check_command python3 && ! check_command python; then
        info_check "Python not installed, skipping"
        return
    fi
    
    local python_cmd="python3"
    if ! check_command python3; then
        python_cmd="python"
    fi
    
    info_check "Python version: $($python_cmd --version)"
    
    # Find requirements.txt files
    local req_files=$(find "$HOME" -name "requirements.txt" -type f 2>/dev/null | wc -l)
    
    if [ "$req_files" -gt 0 ]; then
        pass_check "Found $req_files requirements.txt files"
    fi
    
    # Check for suspicious pip packages
    local pip_list=$($python_cmd -m pip list 2>/dev/null | wc -l)
    if [ "$pip_list" -gt 0 ]; then
        info_check "Python packages installed: $(($pip_list - 2))"
    fi
}

# ============================================================================
# 5. Git Configuration
# ============================================================================

check_git_configuration() {
    write_header "5. Git 設定検証"
    
    if ! check_command git; then
        info_check "Git not installed, skipping"
        return
    fi
    
    info_check "Git version: $(git --version)"
    
    # Check git hooks
    local git_hook_dirs=$(find "$HOME" -name ".git/hooks" -type d 2>/dev/null | wc -l)
    if [ "$git_hook_dirs" -gt 0 ]; then
        info_check "Git repositories with hooks: $git_hook_dirs"
    fi
    
    # Check commit signing
    local sign_commits=$(git config --global commit.gpgsign 2>/dev/null || echo "false")
    if [ "$sign_commits" == "true" ]; then
        pass_check "Git commit signing is enabled"
    else
        warn_check "Git commit signing is disabled"
    fi
    
    # Check for dangerous git aliases
    local dangerous_aliases=$(git config --global --get-regexp '^alias\.' 2>/dev/null | grep -c '\!' || echo "0")
    if [ "$dangerous_aliases" -gt 0 ]; then
        warn_check "Found $dangerous_aliases dangerous git aliases"
    else
        pass_check "No dangerous git aliases detected"
    fi
}

# ============================================================================
# 6. SSH Security
# ============================================================================

check_ssh_security() {
    write_header "6. SSH セキュリティ"
    
    local ssh_dir="$HOME/.ssh"
    
    if [ ! -d "$ssh_dir" ]; then
        info_check "SSH directory not found"
        return
    fi
    
    pass_check "SSH directory exists: $ssh_dir"
    
    # Check .ssh directory permissions (should be 700)
    local ssh_perm=$(stat -L -c %a "$ssh_dir" 2>/dev/null || stat -L -f %OLp "$ssh_dir" 2>/dev/null | tail -c 4)
    if [ "$ssh_perm" == "700" ] || [ "$ssh_perm" == ".rwx------" ]; then
        pass_check ".ssh directory permissions are correct (700)"
    else
        fail_check ".ssh directory has insecure permissions: $ssh_perm"
    fi
    
    # Check for private keys and their permissions
    local key_count=0
    for key in "$ssh_dir"/id_*; do
        [ -f "$key" ] || continue
        [[ "$key" == *.pub ]] && continue
        
        ((key_count++))
        local key_perm=$(stat -L -c %a "$key" 2>/dev/null || stat -L -f %OLp "$key" 2>/dev/null | tail -c 4)
        
        if [ "$key_perm" == "600" ] || [ "$key_perm" == ".rw-------" ]; then
            pass_check "Private key permissions correct: $(basename "$key")"
        else
            fail_check "Private key has insecure permissions: $(basename "$key") ($key_perm)"
        fi
    done
    
    if [ $key_count -eq 0 ]; then
        info_check "No SSH private keys found"
    else
        pass_check "SSH private keys found: $key_count"
    fi
    
    # Check known_hosts
    if [ -f "$ssh_dir/known_hosts" ]; then
        local known_hosts_count=$(wc -l < "$ssh_dir/known_hosts")
        info_check "known_hosts entries: $known_hosts_count"
    fi
}

# ============================================================================
# 7. Environment Variables
# ============================================================================

check_environment_variables() {
    write_header "7. 環境変数セキュリティ"
    
    local suspicious_keywords=("password" "api_key" "token" "secret" "credential" "auth")
    local suspicious_count=0
    
    for keyword in "${suspicious_keywords[@]}"; do
        local found=$(env | grep -i "$keyword" | wc -l)
        if [ "$found" -gt 0 ]; then
            warn_check "Found $found environment variables containing '$keyword'"
            ((suspicious_count += found))
        fi
    done
    
    if [ "$suspicious_count" -eq 0 ]; then
        pass_check "No suspicious environment variables detected"
    fi
    
    # Check for exposed tokens in bash history
    if [ -f "$HOME/.bash_history" ]; then
        local exposed=$(grep -c -i "token=\|api.key\|password=" "$HOME/.bash_history" 2>/dev/null || echo "0")
        if [ "$exposed" -gt 0 ]; then
            fail_check "Found $exposed potential credential exposures in bash history"
        else
            pass_check "No obvious credentials in bash history"
        fi
    fi
}

# ============================================================================
# 8. Firewall Status
# ============================================================================

check_firewall_status() {
    write_header "8. ファイアウォール設定"
    
    if [ "$OS_TYPE" == "macOS" ]; then
        # macOS firewall check
        if check_command launchctl; then
            local fw_status=$(launchctl list | grep -c com.apple.alf.agent || echo "0")
            if [ "$fw_status" -gt 0 ]; then
                pass_check "macOS firewall service is active"
            else
                warn_check "macOS firewall service may not be active"
            fi
        fi
    else
        # Linux firewall check
        if check_command ufw; then
            local ufw_status=$(ufw status 2>/dev/null | grep -c "Status: active" || echo "0")
            if [ "$ufw_status" -gt 0 ]; then
                pass_check "UFW firewall is enabled"
            else
                warn_check "UFW firewall is disabled"
            fi
        elif check_command iptables && [ -f /etc/iptables/rules.v4 ]; then
            pass_check "iptables rules are configured"
        else
            info_check "Firewall status could not be determined"
        fi
    fi
}

# ============================================================================
# 9. Network Connections
# ============================================================================

check_network_connections() {
    write_header "9. ネットワーク接続監視"
    
    if check_command netstat; then
        local established=$(netstat -an 2>/dev/null | grep -c ESTABLISHED || echo "0")
        info_check "Established TCP connections: $established"
        
        local listening=$(netstat -an 2>/dev/null | grep -c LISTEN || echo "0")
        info_check "Listening ports: $listening"
    elif check_command ss; then
        local established=$(ss -tan 2>/dev/null | grep -c ESTAB || echo "0")
        info_check "Established TCP connections: $established"
        
        local listening=$(ss -tan 2>/dev/null | grep -c LISTEN || echo "0")
        info_check "Listening ports: $listening"
    fi
    
    pass_check "Network connection monitoring complete"
}

# ============================================================================
# 10. File System Permissions
# ============================================================================

check_filesystem_permissions() {
    write_header "10. ファイルシステムパーミッション"
    
    # Check critical directories
    local critical_paths=(
        "/etc"
        "/root"
        "/home"
        "$HOME"
    )
    
    for path in "${critical_paths[@]}"; do
        if [ -d "$path" ]; then
            local perms=$(stat -L -c %a "$path" 2>/dev/null || stat -L -f %OLp "$path" 2>/dev/null | tail -c 4)
            info_check "$path permissions: $perms"
        fi
    done
    
    pass_check "File system permissions checked"
}

# ============================================================================
# 11. Process Monitoring
# ============================================================================

check_process_monitoring() {
    write_header "11. プロセス監視"
    
    if check_command ps; then
        # Check for suspicious processes
        local proc_count=$(ps aux 2>/dev/null | wc -l)
        info_check "Active processes: $proc_count"
        
        # Look for suspicious patterns
        local suspicious=$(ps aux 2>/dev/null | grep -E "(nc|ncat|netcat|socat|xxd|curl.*\|)" | grep -v grep | wc -l)
        
        if [ "$suspicious" -gt 0 ]; then
            warn_check "Found $suspicious potentially suspicious processes"
        else
            pass_check "No obviously suspicious processes detected"
        fi
    fi
}

# ============================================================================
# 12. Cron Jobs
# ============================================================================

check_cron_jobs() {
    write_header "12. Cron ジョブ監査"
    
    if check_command crontab; then
        # Check user cron jobs
        local cron_entries=$(crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$" | wc -l || echo "0")
        
        if [ "$cron_entries" -gt 0 ]; then
            info_check "User cron jobs found: $cron_entries"
            crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$" | while read -r job; do
                info_check "  Cron: $job"
            done
        else
            pass_check "No user cron jobs found"
        fi
    fi
    
    # Check system cron
    if [ -d "/etc/cron.d" ]; then
        local sys_cron=$(find /etc/cron* -type f 2>/dev/null | wc -l)
        info_check "System cron jobs: $sys_cron"
    fi
}

# ============================================================================
# Summary Report
# ============================================================================

generate_summary() {
    echo -e "\n${CYAN}================================================================================${NC}"
    echo -e "${CYAN}SECURITY CHECK SUMMARY${NC}"
    echo -e "${CYAN}================================================================================${NC}\n"
    
    echo -e "${GREEN}✓ Passed:${NC}  $CHECKS_PASSED"
    echo -e "${RED}✗ Failed:${NC}  $CHECKS_FAILED"
    echo -e "${YELLOW}⚠ Warned:${NC}  $CHECKS_WARNED"
    echo -e "${BLUE}ℹ Infos:${NC}   $CHECKS_INFO"
    
    local total=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNED + CHECKS_INFO))
    
    if [ "$CHECKS_FAILED" -eq 0 ]; then
        echo -e "\n${GREEN}✓ No critical issues detected${NC}"
    elif [ "$CHECKS_FAILED" -gt 5 ]; then
        echo -e "\n${RED}✗ Multiple critical issues detected - immediate action recommended${NC}"
    else
        echo -e "\n${YELLOW}⚠ Some issues require attention${NC}"
    fi
    
    echo -e "\nReport saved to: ${GREEN}$REPORT_FILE${NC}"
    echo -e "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    
    # Write to report
    write_log ""
    write_log "================================================================================"
    write_log "SUMMARY"
    write_log "================================================================================"
    write_log "Passed:  $CHECKS_PASSED"
    write_log "Failed:  $CHECKS_FAILED"
    write_log "Warned:  $CHECKS_WARNED"
    write_log "Infos:   $CHECKS_INFO"
    write_log "Total:   $total"
    write_log ""
    write_log "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    detect_os
    
    echo -e "\n${CYAN}================================================================================${NC}"
    echo -e "${CYAN}SUPPLY CHAIN SECURITY CHECK - $(echo "$OS_TYPE" | tr a-z A-Z)${NC}"
    echo -e "${CYAN}================================================================================${NC}"
    echo -e "${GRAY}Started: $(date '+%Y-%m-%d %H:%M:%S')${NC}\n"
    
    # Initialize report
    write_log "SUPPLY CHAIN SECURITY CHECK - $OS_TYPE"
    write_log "Started: $(date '+%Y-%m-%d %H:%M:%S')"
    write_log "Hostname: $(hostname)"
    write_log "OS Type: $OS_TYPE"
    write_log "Kernel: $(uname -r)"
    write_log ""
    
    # Run all checks
    check_code_signatures
    check_gpg_signatures
    check_npm_packages
    check_python_packages
    check_git_configuration
    check_ssh_security
    check_environment_variables
    check_firewall_status
    check_network_connections
    check_filesystem_permissions
    check_process_monitoring
    check_cron_jobs
    
    # Generate summary
    generate_summary
}

# Execute
main "$@"
