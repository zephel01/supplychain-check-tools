# Supply Chain Security Check Tool - 実装ガイド
## Implementation Guide & Technical Details

---

## 📚 目次

1. [アーキテクチャ概要](#アーキテクチャ概要)
2. [チェック機構の詳細](#チェック機構の詳細)
3. [各スクリプトの使い方](#各スクリプトの使い方)
4. [カスタマイズガイド](#カスタマイズガイド)
5. [トラブルシューティング](#トラブルシューティング)
6. [セキュリティベストプラクティス](#セキュリティベストプラクティス)

---

## アーキテクチャ概要

### スクリプト構成

```
supply-chain-check-tools/
├── README.md                          # メインドキュメント
├── IMPLEMENTATION_GUIDE.md            # このファイル
├── check-supply-chain-windows.ps1     # Windows用（PowerShell）
├── check-supply-chain-unix.sh         # macOS/Linux用（Bash）
└── check-supply-chain-rpi.sh          # Raspberry Pi OS用（最適化）
```

### 実行フロー

```
スクリプト実行
  ↓
┌─────────────────────────────────┐
│ 環境検出 & 初期化                 │
│ - OSタイプ判定                   │
│ - 権限確認                       │
│ - レポートファイル作成            │
└─────────────────────────────────┘
  ↓
┌─────────────────────────────────┐
│ 順次チェック実行 (各カテゴリ)     │
│ 1. コード署名検証                │
│ 2. パッケージ検証                │
│ 3. Git設定確認                  │
│ ... (合計10-12項目)              │
└─────────────────────────────────┘
  ↓
┌─────────────────────────────────┐
│ レポート生成                      │
│ - 統計情報集計                   │
│ - ファイル出力                   │
│ - サマリー表示                   │
└─────────────────────────────────┘
```

---

## チェック機構の詳細

### 1. コード署名検証 (Code Signature Verification)

#### Windows (Authenticode)
```powershell
# PowerShell実装
Get-AuthenticodeSignature -FilePath $file.FullName

# 検証項目:
✓ 署名の有効性
✓ 署名チェーン (CA信頼性)
✓ タイムスタンプ検証
✓ 失効チェック (CRL)
```

#### macOS (Code Signing + Notarization)
```bash
# Shell実装
codesign -v /path/to/app
spctl --assess --type execute /path/to/app

# 検証項目:
✓ コード署名の有効性
✓ Notarization ステータス
✓ Gatekeeper互換性
```

#### Linux (Permission & GnuPG)
```bash
# パーミッション確認
stat -L -c %a /usr/bin/binary
ls -la /usr/bin/binary

# GnuPG署名検証
gpg --verify binary.sig binary
```

### 2. パッケージ依存性チェック (Package Dependency Verification)

#### npm
```bash
# lock file整合性
ls -la package-lock.json
npm ci --dry-run

# セキュリティ監査
npm audit --audit-level=moderate
npm list --depth=0
```

**チェック内容:**
- `package-lock.json` の存在確認
- `node_modules/` のハッシュ値検証
- 脆弱性データベース照合
- 重複パッケージ検出

#### Python
```bash
# 仮想環境確認
python3 -m venv --help

# パッケージ整合性
pip verify (または hash checks)
pip list --format=columns

# セキュリティチェック
pip check
safety check
```

#### Ruby Gems
```bash
# Gem署名確認
gem cert --list

# インストール済みGem検証
gem cert --verify
```

#### Cargo
```bash
# Cargo.lock 検証
cargo tree --depth 0

# セキュリティ監査
cargo audit
```

### 3. Git設定検証

```bash
# 危険な設定検出
git config --list --show-origin

# 検証項目:
✓ コミット署名設定 (commit.gpgsign)
✓ Git Hooks権限 (700以下)
✓ 危険なaliases (shell injection)
✓ リモートURL (https vs http)
```

**危険なパターン:**
```bash
# ❌ 危険
alias.log = !cat /etc/passwd
alias.revert = !rm -rf .git

# ✅ 安全
commit.gpgsign = true
pull.rebase = true
```

### 4. SSH セキュリティ

```bash
# パーミッション確認 (Linux/macOS)
stat -c "%a %U:%G" ~/.ssh/id_rsa    # 600 root:root 推奨
stat -c "%a" ~/.ssh                  # 700 推奨

# 鍵チェーン確認 (macOS)
security dump-keychain-passwords

# キー登録確認
ssh-add -L
```

**推奨設定:**
```
~/.ssh/               : 700 (drwx------)
~/.ssh/id_rsa         : 600 (-rw-------)
~/.ssh/id_rsa.pub     : 644 (-rw-r--r--)
~/.ssh/authorized_keys: 600 (-rw-------)
~/.ssh/config         : 600 (-rw-------)
```

### 5. 環境変数・認証情報チェック

```bash
# 疑わしい環境変数
env | grep -i "password\|api\|token\|secret"

# Bashヒストリから検出
grep -i "export.*password\|export.*token" ~/.bash_history

# 機密情報の露出スキャン
grep -r "password.*=" . --include="*.env" --include="*.sh"
```

**検出パターン:**
```bash
# ❌ 検出される危険な設定
export API_KEY=sk_live_xxxxx
export DB_PASSWORD=admin123
export GITHUB_TOKEN=ghp_xxxxx
DATABASE_URL=postgresql://user:pass@localhost

# ✅ 安全な設定
export CONFIG_PATH=/etc/app/config
export LOG_LEVEL=debug
export ENVIRONMENT=production
```

### 6. ファイアウォール & ネットワーク

#### Windows
```powershell
# ファイアウォールプロファイル確認
Get-NetFirewallProfile | Select Name, Enabled

# ルール確認
Get-NetFirewallRule -Enabled $true | Where {$_.Direction -eq "Inbound"}
```

#### Linux
```bash
# UFW (Ubuntu)
ufw status verbose
ufw show added

# iptables
sudo iptables -L -n -v
sudo iptables -S

# ss コマンド
ss -tulpn | grep LISTEN
```

#### macOS
```bash
# Firewall設定
system_profiler SPFirewallDataType

# PF (Packet Filter)
sudo pfctl -sr
```

### 7. プロセス監視

```bash
# 疑わしいプロセス検出
ps aux | grep -E "nc|ncat|netcat|socat|xxd"

# ネットワーク接続プロセス
netstat -tulpn | grep ESTABLISHED
lsof -i -P -n

# メモリ使用量が多いプロセス
ps aux --sort=-%mem | head -10
```

---

## 各スクリプトの使い方

### Windows PowerShell版

#### 前提条件
```powershell
# PowerShellバージョン確認
$PSVersionTable.PSVersion

# 実行ポリシー確認
Get-ExecutionPolicy -Scope CurrentUser
```

#### 実行方法

```powershell
# 方法1: 一時的な実行許可 (推奨)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\check-supply-chain-windows.ps1

# 方法2: スクリプトを署名して実行 (企業環境推奨)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 管理者権限での実行
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\check-supply-chain-windows.ps1`"" -Verb RunAs

# verbose出力
.\check-supply-chain-windows.ps1 -Verbose
```

#### 出力ファイル
```
supply_chain_check_report_20260403_143022.txt
```

---

### macOS / Linux Bash版

#### 前提条件
```bash
# Bashバージョン確認 (4.0+推奨)
bash --version

# 必要なコマンド確認
which git npm python3 gpg ssh codesign
```

#### 実行方法

```bash
# 基本的な実行
chmod +x check-supply-chain-unix.sh
./check-supply-chain-unix.sh

# 管理者権限で実行 (ネットワークチェック有効)
sudo ./check-supply-chain-unix.sh

# バックグラウンド実行
./check-supply-chain-unix.sh &

# ログに保存しながら実行
./check-supply-chain-unix.sh | tee output.log

# cron自動実行
0 2 * * 0 /path/to/check-supply-chain-unix.sh >> /var/log/supply-chain-check.log 2>&1
```

#### 出力ファイル
```
supply_chain_check_report_20260403_143022.txt
```

---

### Raspberry Pi OS版

#### 特有の環境変数

```bash
# 軽量モード (デフォルト有効)
export LIGHTWEIGHT_MODE=1
./check-supply-chain-rpi.sh

# フルモード (リソース多消費)
export LIGHTWEIGHT_MODE=0
./check-supply-chain-rpi.sh
```

#### 実行方法

```bash
# 標準実行
chmod +x check-supply-chain-rpi.sh
./check-supply-chain-rpi.sh

# 温度監視付き実行
watch -n 5 "vcgencmd measure_temp"  # 別ウィンドウで実行
./check-supply-chain-rpi.sh

# systemdサービス化
sudo cp check-supply-chain-rpi.sh /usr/local/bin/
sudo nano /etc/systemd/system/supply-chain-check.service
```

#### systemdサービス設定例

```ini
[Unit]
Description=Supply Chain Security Check
After=network-online.target

[Service]
Type=oneshot
User=pi
ExecStart=/usr/local/bin/check-supply-chain-rpi.sh
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

```bash
# サービス登録
sudo systemctl daemon-reload
sudo systemctl enable supply-chain-check
sudo systemctl start supply-chain-check
```

---

## カスタマイズガイド

### チェック項目の追加

#### Bash (Unix版)

```bash
# 新しいチェック関数追加
check_custom_security_check() {
    write_header "新しいセキュリティチェック"
    
    # カスタムロジック
    if [ -f /etc/security/custom.conf ]; then
        pass_check "カスタム設定が存在"
    else
        fail_check "カスタム設定が見つかりません"
    fi
}

# main() 関数内に追加
main() {
    # ... 既存チェック ...
    check_custom_security_check  # ← ここに追加
    # ... 残りのチェック ...
}
```

#### PowerShell (Windows版)

```powershell
function Check-CustomSecurity {
    Write-LogHeader "カスタムセキュリティチェック"
    
    # カスタムロジック
    if (Test-Path "HKLM:\Software\Custom") {
        Write-PassCheck "カスタムレジストリキーが存在"
    } else {
        Write-FailCheck "カスタムレジストリキーが見つかりません"
    }
}

# Main 関数内に追加
function Main {
    # ... 既存チェック ...
    Check-CustomSecurity  # ← ここに追加
    # ... 残りのチェック ...
}
```

### チェック項目の無効化

```bash
# チェック関数の呼び出しをコメントアウト
# check_npm_packages      # ← 無効化
check_python_packages     # ← 有効
```

### 独立した検査スクリプトの統合

```bash
#!/bin/bash
# カスタム検査スクリプト: custom_check.sh

source ./check-supply-chain-unix.sh  # 関数インポート

# カスタム実装
my_custom_check() {
    write_header "カスタム検査"
    # ロジック
}

# 実行
my_custom_check
```

---

## トラブルシューティング

### Windows PowerShell

#### 問題: 実行ポリシーエラー
```
カテゴリ : セキュリティエラー
実行ポリシー: Restricted
```

**解決方法:**
```powershell
# 一時的に許可
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# または署名付きスクリプトとして実行
Set-AuthenticodeSignature -FilePath .\script.ps1 -Certificate (Get-ChildItem Cert:\)
```

#### 問題: 管理者権限不足
```
"Get-NetFirewallProfile" コマンドレットに認識されません
```

**解決方法:**
```powershell
# PowerShellを管理者として起動
Start-Process powershell -Verb RunAs

# または実行時に指定
powershell -NoProfile -Command "& {Start-Process powershell -Verb RunAs}"
```

---

### Bash (Unix)

#### 問題: Permission denied
```
bash: ./check-supply-chain-unix.sh: Permission denied
```

**解決方法:**
```bash
# 実行権限追加
chmod +x check-supply-chain-unix.sh

# または直接実行
bash check-supply-chain-unix.sh
```

#### 問題: コマンドが見つからない
```
npm: command not found
```

**解決方法:**
```bash
# PATH確認
echo $PATH

# パッケージマネージャでインストール
# Ubuntu/Debian
sudo apt install npm

# macOS
brew install node
```

#### 問題: Raspberry Pi メモリ不足
```
メモリ: 0MB / 900MB
```

**解決方法:**
```bash
# 軽量モード使用
export LIGHTWEIGHT_MODE=1
./check-supply-chain-rpi.sh

# または個別チェックのみ実行
bash -c 'source ./check-supply-chain-unix.sh; check_ssh_security'
```

---

### Raspberry Pi OS特有の問題

#### 問題: GPIO権限不足
```
GPIO directory permissions: 755 (should be writable)
```

**解決方法:**
```bash
# ユーザをgpioグループに追加
sudo usermod -a -G gpio $USER

# ログアウト/ログインして反映
```

#### 問題: 温度センサーが利用不可
```
CPU temperature: check failed
```

**解決方法:**
```bash
# 温度ファイル確認
ls -la /sys/class/thermal/

# vcgencmdツール確認
which vcgencmd
vcgencmd measure_temp
```

---

## セキュリティベストプラクティス

### 1. レポート管理

```bash
# レポートを安全に保存
mkdir -p ~/security_reports
chmod 700 ~/security_reports

# 定期バックアップ
cp supply_chain_check_report_*.txt ~/security_reports/
gzip ~/security_reports/supply_chain_check_report_*.txt
```

### 2. 自動実行の設定

#### Linux cron での安全な設定
```bash
# /etc/cron.d/supply-chain-check
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=admin@example.com

0 2 * * 0 /root/scripts/check-supply-chain-unix.sh >> /var/log/supply-chain-check.log 2>&1
```

### 3. ログ管理

```bash
# 専用ログディレクトリ作成
sudo mkdir -p /var/log/security-audit
sudo chmod 700 /var/log/security-audit

# ログローテーション設定
sudo nano /etc/logrotate.d/security-audit
```

設定例:
```
/var/log/security-audit/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 0600 root root
}
```

### 4. 結果の暗号化と転送

```bash
# レポート暗号化
gpg --symmetric supply_chain_check_report_*.txt

# リモート転送 (SFTP推奨)
sftp user@secure.server.com
put supply_chain_check_report_*.txt.gpg

# または secure-copy
scp -i ~/.ssh/id_rsa supply_chain_check_report_*.txt secure-server:/backups/
```

### 5. チーム間での共有

```bash
# レポートの共有 (権限管理)
chmod 640 supply_chain_check_report_*.txt
chown root:audit_team supply_chain_check_report_*.txt

# 中央リポジトリへの提出
git add supply_chain_check_report_*.txt
git commit -m "Security audit: $(date +%Y-%m-%d)"
```

---

## 参考資料

### セキュリティ標準
- [NIST SP 800-53: Security and Privacy Controls](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [CIS Controls](https://www.cisecurity.org/cis-controls/)
- [OWASP Top 10](https://owasp.org/Top10/)

### ツール参考
- [npm audit documentation](https://docs.npmjs.com/cli/v8/commands/npm-audit)
- [Python pip security](https://pip.pypa.io/en/stable/reference/pip_install/)
- [Git security best practices](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)
- [codesign manual (macOS)](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/)

---

**最終更新**: 2026年4月
**バージョン**: 1.0.0
**ライセンス**: MIT
