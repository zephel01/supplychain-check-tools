#!/bin/bash

################################################################################
# Supply Chain Security Check Tool - Raspberry Pi OS
# ARM最適化版 - リソース制限対応
################################################################################

set -o pipefail

# Configuration for Raspberry Pi
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="supply_chain_check_report_${TIMESTAMP}.txt"
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNED=0
CHECKS_INFO=0

# Memory-efficient mode (disable for full checks)
LIGHTWEIGHT_MODE="${LIGHTWEIGHT_MODE:-1}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# ============================================================================
# Utility Functions (optimized for ARM)
# ============================================================================

write_log() {
    echo "$1" >> "$REPORT_FILE"
}

write_header() {
    local header="$1"
    local separator="=========================================="
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
    echo -e "${GREEN}✓${NC} $message"
    write_log "✓ $message"
    ((CHECKS_PASSED++))
}

fail_check() {
    local message="$1"
    echo -e "${RED}✗${NC} $message"
    write_log "✗ $message"
    ((CHECKS_FAILED++))
}

warn_check() {
    local message="$1"
    echo -e "${YELLOW}⚠${NC} $message"
    write_log "⚠ $message"
    ((CHECKS_WARNED++))
}

info_check() {
    local message="$1"
    echo -e "${BLUE}ℹ${NC} $message"
    write_log "ℹ $message"
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
# ARM-Optimized Checks
# ============================================================================

check_system_info() {
    write_header "1. システム情報"
    
    # Get CPU info
    local cpu_info=$(grep -o 'ARMv[0-9]' /proc/cpuinfo | head -1 || echo "Unknown")
    info_check "CPU Architecture: $cpu_info"
    
    # Get Raspberry Pi model
    if [ -f /proc/device-tree/model ]; then
        local rpi_model=$(cat /proc/device-tree/model 2>/dev/null)
        info_check "Board: $rpi_model"
    fi
    
    # Memory usage
    local mem_total=$(free -h | awk 'NR==2 {print $2}')
    local mem_used=$(free -h | awk 'NR==2 {print $3}')
    info_check "Memory: $mem_used / $mem_total"
    
    # Check for Lightweight Mode
    if [ "$LIGHTWEIGHT_MODE" == "1" ]; then
        info_check "Lightweight Mode: ENABLED (reduced checks)"
    else
        info_check "Lightweight Mode: DISABLED (full checks)"
    fi
}

check_ssh_security() {
    write_header "2. SSH セキュリティ"
    
    # Check if SSH is running
    if systemctl is-active --quiet ssh 2>/dev/null || systemctl is-active --quiet sshd 2>/dev/null; then
        pass_check "SSH service is running"
    else
        warn_check "SSH service is not running"
    fi
    
    # Check SSH keys
    local ssh_dir="$HOME/.ssh"
    if [ ! -d "$ssh_dir" ]; then
        info_check "SSH directory not configured"
        return
    fi
    
    # Check .ssh directory permissions
    local ssh_perm=$(stat -c %a "$ssh_dir" 2>/dev/null)
    if [ "$ssh_perm" == "700" ]; then
        pass_check ".ssh directory permissions correct (700)"
    else
        warn_check ".ssh directory permissions: $ssh_perm (should be 700)"
    fi
    
    # Check for private keys
    local key_count=$(find "$ssh_dir" -maxdepth 1 -name "id_*" ! -name "*.pub" 2>/dev/null | wc -l)
    if [ "$key_count" -gt 0 ]; then
        pass_check "SSH private keys found: $key_count"
    else
        info_check "No SSH private keys found"
    fi
}

check_package_managers() {
    write_header "3. パッケージマネージャ確認"
    
    # Check apt updates
    if check_command apt; then
        info_check "APT package manager available"
        
        # List update status (lightweight)
        local updates=$(apt list --upgradable 2>/dev/null | tail -1 | grep -o '[0-9]* upgradable' || echo "0")
        if [[ "$updates" =~ "0 upgradable" ]]; then
            pass_check "System is up to date"
        else
            info_check "Available updates: $updates"
        fi
    fi
    
    # Check pip
    if check_command pip3; then
        info_check "pip3 available"
    elif check_command pip; then
        info_check "pip available"
    fi
}

check_git_repos() {
    write_header "4. Git リポジトリ監査"
    
    if ! check_command git; then
        info_check "Git not installed"
        return
    fi
    
    info_check "Git version: $(git --version 2>/dev/null)"
    
    # Find .git directories (limit search depth to save resources)
    local repo_count=$(find "$HOME" -maxdepth 3 -type d -name ".git" 2>/dev/null | wc -l)
    
    if [ "$repo_count" -gt 0 ]; then
        info_check "Git repositories found: $repo_count"
        
        # Check commit signing
        local sign_commits=$(git config --global commit.gpgsign 2>/dev/null || echo "false")
        if [ "$sign_commits" == "true" ]; then
            pass_check "Git commit signing enabled"
        else
            warn_check "Git commit signing disabled"
        fi
    else
        info_check "No git repositories found"
    fi
}

check_file_integrity() {
    write_header "5. ファイルシステム整合性"
    
    # Check critical system files (ARM-optimized - fewer files)
    local critical_files=(
        "/boot"
        "/root"
        "$HOME"
    )
    
    for path in "${critical_files[@]}"; do
        if [ -d "$path" ]; then
            local perm=$(stat -c %a "$path" 2>/dev/null)
            info_check "$path permissions: $perm"
        fi
    done
    
    # Check for SUID/SGID binaries (limited scan)
    if [ "$LIGHTWEIGHT_MODE" != "1" ]; then
        local suid_count=$(find /usr/bin -perm /6000 -type f 2>/dev/null | wc -l)
        info_check "SUID/SGID binaries in /usr/bin: $suid_count"
    else
        info_check "SUID/SGID check skipped (lightweight mode)"
    fi
}

check_network_config() {
    write_header "6. ネットワーク設定"
    
    # Check network interface
    if check_command ip; then
        local interfaces=$(ip link show 2>/dev/null | grep "^[0-9]" | wc -l)
        info_check "Network interfaces: $interfaces"
    fi
    
    # Check if wireless is running
    if check_command iwconfig 2>/dev/null; then
        local wifi=$(iwconfig 2>/dev/null | grep -c "ESSID" || echo "0")
        if [ "$wifi" -gt 0 ]; then
            info_check "WiFi is connected"
        else
            info_check "WiFi is not connected"
        fi
    fi
    
    # Check listening ports (lightweight)
    if check_command ss; then
        local listening=$(ss -tulpn 2>/dev/null | grep LISTEN | wc -l)
        info_check "Listening ports: $listening"
    elif check_command netstat; then
        local listening=$(netstat -tulpn 2>/dev/null | grep LISTEN | wc -l)
        info_check "Listening ports: $listening"
    fi
}

check_gpio_security() {
    write_header "7. GPIO セキュリティ (RPi特有)"
    
    # Check GPIO permissions (Raspberry Pi specific)
    if [ -d "/sys/class/gpio" ]; then
        local gpio_perm=$(stat -c %a /sys/class/gpio 2>/dev/null)
        info_check "GPIO directory permissions: $gpio_perm"
        
        if groups | grep -q "gpio"; then
            pass_check "Current user is in gpio group"
        else
            info_check "Current user is not in gpio group"
        fi
    else
        info_check "GPIO interface not available"
    fi
    
    # Check device tree
    if [ -f /proc/device-tree/model ]; then
        pass_check "Device tree available"
    fi
}

check_boot_config() {
    write_header "8. ブート設定確認"
    
    # Check boot configuration
    if [ -f /boot/cmdline.txt ]; then
        info_check "Boot configuration found"
        
        # Check for dangerous boot parameters
        if grep -q "permissive" /boot/cmdline.txt 2>/dev/null; then
            warn_check "SELinux permissive mode detected in boot config"
        fi
    fi
    
    # Check bootloader version
    if check_command vcgencmd 2>/dev/null; then
        local bootloader=$(vcgencmd bootloader_version 2>/dev/null)
        info_check "Bootloader: $bootloader"
    fi
}

check_process_security() {
    write_header "9. プロセス監視"
    
    if check_command ps; then
        local proc_count=$(ps aux 2>/dev/null | wc -l)
        info_check "Active processes: $proc_count"
        
        # Check for suspicious processes (lightweight)
        local suspicious=$(ps aux 2>/dev/null | grep -E "(nc|netcat|wget|curl)" | grep -v grep | wc -l || echo "0")
        
        if [ "$suspicious" -eq 0 ]; then
            pass_check "No obviously suspicious processes detected"
        else
            warn_check "Found $suspicious processes with network tools"
        fi
    fi
}

check_disk_space() {
    write_header "10. ディスク容量"
    
    # Check disk usage
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}')
    info_check "Root filesystem usage: $disk_usage"
    
    # Check if usage is critical
    local usage_percent=${disk_usage%\%}
    if [ "$usage_percent" -gt 90 ]; then
        fail_check "Disk usage critical: $disk_usage"
    elif [ "$usage_percent" -gt 80 ]; then
        warn_check "Disk usage high: $disk_usage"
    else
        pass_check "Disk usage normal: $disk_usage"
    fi
    
    # Check boot partition if exists
    if [ -d /boot ]; then
        local boot_usage=$(df -h /boot | awk 'NR==2 {print $5}')
        info_check "Boot partition usage: $boot_usage"
    fi
}

check_environment_vars() {
    write_header "11. 環境変数確認"
    
    # Check for suspicious environment variables
    local suspicious=0
    
    for keyword in password api token secret; do
        local count=$(env | grep -i "$keyword" | wc -l)
        if [ "$count" -gt 0 ]; then
            warn_check "Found $count env vars with '$keyword'"
            ((suspicious += count))
        fi
    done
    
    if [ "$suspicious" -eq 0 ]; then
        pass_check "No suspicious environment variables"
    fi
}

check_temperature() {
    write_header "12. システム温度 (RPi特有)"
    
    # Check CPU temperature
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        local temp_raw=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
        local temp=$((temp_raw / 1000))
        info_check "CPU temperature: ${temp}°C"
        
        if [ "$temp" -gt 85 ]; then
            warn_check "High CPU temperature detected: ${temp}°C"
        elif [ "$temp" -gt 70 ]; then
            info_check "CPU temperature is elevated: ${temp}°C"
        else
            pass_check "CPU temperature normal: ${temp}°C"
        fi
    fi
    
    # GPU temperature (if available)
    if check_command vcgencmd 2>/dev/null; then
        local gpu_temp=$(vcgencmd measure_temp 2>/dev/null | grep -o '[0-9]*\.[0-9]*' | head -1)
        if [ ! -z "$gpu_temp" ]; then
            info_check "GPU temperature: ${gpu_temp}°C"
        fi
    fi
}

# ============================================================================
# Summary
# ============================================================================

generate_summary() {
    echo -e "\n${CYAN}===========================================${NC}"
    echo -e "${CYAN}SECURITY CHECK SUMMARY (Raspberry Pi)${NC}"
    echo -e "${CYAN}===========================================${NC}\n"
    
    echo -e "${GREEN}✓${NC} Passed:  $CHECKS_PASSED"
    echo -e "${RED}✗${NC} Failed:  $CHECKS_FAILED"
    echo -e "${YELLOW}⚠${NC} Warned:  $CHECKS_WARNED"
    echo -e "${BLUE}ℹ${NC} Infos:   $CHECKS_INFO"
    
    local total=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNED + CHECKS_INFO))
    
    if [ "$CHECKS_FAILED" -eq 0 ]; then
        echo -e "\n${GREEN}✓ Security check passed${NC}"
    else
        echo -e "\n${YELLOW}⚠ Issues found - review report${NC}"
    fi
    
    echo -e "\nReport: ${GREEN}$REPORT_FILE${NC}"
    echo -e "Time: $(date '+%Y-%m-%d %H:%M:%S')"
    
    # Write summary
    write_log ""
    write_log "==========================================="
    write_log "SUMMARY"
    write_log "==========================================="
    write_log "Passed:  $CHECKS_PASSED"
    write_log "Failed:  $CHECKS_FAILED"
    write_log "Warned:  $CHECKS_WARNED"
    write_log "Infos:   $CHECKS_INFO"
    write_log "Total:   $total"
    write_log ""
    write_log "Lightweight Mode: $LIGHTWEIGHT_MODE"
    write_log "Time: $(date '+%Y-%m-%d %H:%M:%S')"
}

# ============================================================================
# Main
# ============================================================================

main() {
    echo -e "\n${CYAN}===========================================${NC}"
    echo -e "${CYAN}SUPPLY CHAIN SECURITY CHECK${NC}"
    echo -e "${CYAN}Raspberry Pi OS (ARM Optimized)${NC}"
    echo -e "${CYAN}===========================================${NC}"
    echo -e "${GRAY}Started: $(date '+%Y-%m-%d %H:%M:%S')${NC}\n"
    
    # Initialize report
    write_log "SUPPLY CHAIN SECURITY CHECK - Raspberry Pi OS"
    write_log "ARM Optimized Version"
    write_log "Started: $(date '+%Y-%m-%d %H:%M:%S')"
    write_log "Hostname: $(hostname)"
    write_log "Kernel: $(uname -r)"
    write_log "Lightweight Mode: $LIGHTWEIGHT_MODE"
    write_log ""
    
    # Run checks
    check_system_info
    check_ssh_security
    check_package_managers
    check_git_repos
    check_file_integrity
    check_network_config
    check_gpio_security
    check_boot_config
    check_process_security
    check_disk_space
    check_environment_vars
    check_temperature
    
    # Summary
    generate_summary
}

main "$@"
