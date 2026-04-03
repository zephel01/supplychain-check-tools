# Supply Chain Security Check Tool
## サプライチェーン攻撃防止 ローカル環境チェックツール

包括的なセキュリティ監査ツールセット - 複数プラットフォーム対応

---

## 📋 概要

このツールセットは、サプライチェーン攻撃から開発環境を保護するための **包括的なセキュリティチェック機構** を提供します。

### 対応プラットフォーム

- ✅ **Windows** (PowerShell 5.0+)
- ✅ **macOS** (Bash 4.0+)
- ✅ **Linux / Ubuntu** (Bash 4.0+)
- ✅ **Raspberry Pi OS** (ARM最適化版)

---

## 🎯 主な機能

### 1. パッケージ依存性チェック
- npm packages (lock file検証、整合性確認)
- Python pip (パッケージハッシュ検証)
- Ruby Gems (署名確認)
- Cargo (Rust - Cargo.lock検証)

### 2. バイナリ・実行ファイル検証
- **Windows**: Authenticode署名検証
- **macOS**: コード署名 + Notarization確認
- **Linux**: 実行権限・所有者確認
- **GnuPG署名**: 汎用署名検証

### 3. 開発者ツール・プラグイン監査
- Git設定・Hooks検証
- IDE Plugin (VS Code, JetBrains等) スキャン
- Build Tool設定 (Maven, Gradle等)
- Docker/Container設定チェック

### 4. システム設定・ネットワーク
- ファイアウォール状態確認
- オープンポート・リスニングサービス検出
- 疑わしいプロセス・接続検出
- ファイルシステムパーミッション監査

### 5. 認証情報・環境変数
- コード内の機密情報露出検出
- SSH key権限確認 (600/700)
- GitHubトークン・API Key管理監査
- シェル設定ファイル (.bashrc/.zshrc) の危険性検出

---

## 🚀 クイックスタート

### Windows

```powershell
# PowerShellをダウンロード
# 実行前に実行ポリシーを確認
Get-ExecutionPolicy

# 実行 (管理者権限推奨)
.\check-supply-chain-windows.ps1

# 結果確認
cat supply_chain_check_report_*.txt
```

### macOS / Linux

```bash
# ダウンロード
chmod +x check-supply-chain-unix.sh

# 実行 (sudo不要だが、一部チェックは推奨)
./check-supply-chain-unix.sh

# または管理者権限で実行
sudo ./check-supply-chain-unix.sh

# 結果確認
cat supply_chain_check_report_*.txt
```

### Raspberry Pi OS

```bash
# ダウンロード
chmod +x check-supply-chain-rpi.sh

# ARM最適化版実行
./check-supply-chain-rpi.sh

# 結果確認
cat supply_chain_check_report_*.txt
```

---

## 📊 チェック項目詳細

### パッケージ依存性 (Package Dependencies)

#### npm (Node.js)
```
✓ package-lock.json の完全性検証
✓ node_modules/ の改ざん検出
✓ npm audit でセキュリティ脆弱性確認
✓ 予期しない外部パッケージ検出
```

#### Python (pip)
```
✓ requirements.txt / Pipfile の整合性確認
✓ パッケージハッシュ検証
✓ pip list で重複・不正パッケージ検出
✓ Virtual environment独立性確認
```

#### Ruby Gems
```
✓ Gemfile.lock の署名確認
✓ gem cert でインストール済みGem検証
```

#### Cargo (Rust)
```
✓ Cargo.lock の整合性確認
✓ Registry source確認
```

---

### バイナリ・実行ファイル検証 (Binary Verification)

#### Windows
```
✓ .exe / .dll ファイルの Authenticode 署名
✓ 署名の信頼性チェーン確認
✓ タイムスタンプ検証
✓ 修正/改ざんの痕跡検出
```

#### macOS
```
✓ codesign -v コード署名確認
✓ spctl デジタルNotarization検証
✓ Gatekeeper互換性確認
```

#### Linux
```
✓ 実行ファイル所有者確認
✓ SUID/SGID ビット監査
✓ 異常なファイルパーミッション検出
✓ バイナリの署名 (GnuPG) 検証
```

---

### 開発者ツール (Developer Tools)

#### Git設定
```
✓ .git/config の権限確認
✓ Git hooks の整合性確認
✓ コミット署名設定確認
✓ 危険なgit aliases検出
```

#### IDE/エディタプラグイン
```
✓ VS Code extensions フォルダスキャン
✓ JetBrains IDE plugins 確認
✓ プラグインの出所・署名検証
✓ アップデート機構チェック
```

---

### システムセキュリティ (System Security)

#### ファイアウォール
```
✓ Windows: Windows Defender Firewall状態
✓ macOS: pf / ALF状態確認
✓ Linux: UFW / iptables ルール確認
```

#### ネットワーク
```
✓ オープンポート一覧取得
✓ リスニングプロセス確認
✓ 予期しない接続検出
```

#### プロセス監視
```
✓ 疑わしいバックグラウンドプロセス検出
✓ 異常な権限昇格試行検出
✓ ネットワークアクティビティ監査
```

---

### 認証情報管理 (Credentials)

#### SSH/GPG
```
✓ ~/.ssh ディレクトリ権限 (700推奨)
✓ 秘密鍵ファイル権限 (600推奨)
✓ known_hosts の整合性確認
✓ GPG鍵の有効性確認
```

#### 環境変数・トークン
```
✓ bash_history からAPI key/token検出
✓ .bashrc / .zshrc 内の秘密情報露出検出
✓ 環境変数の危険な設定検出
✓ GitHubトークン権限スコープ確認
```

---

## 📈 出力レポート

スクリプト実行後、以下の形式でレポートが生成されます：

```
supply_chain_check_report_YYYYMMDD_HHMMSS.txt
```

レポート内容：
- ✅ **PASS**: セキュリティ要件を満たしている
- ⚠️ **WARN**: 注意が必要な設定
- ❌ **FAIL**: 即座の対応が必要
- ℹ️ **INFO**: 参考情報

---

## 🔧 カスタマイズガイド

### チェック項目を無効にする

スクリプト内の対応する行をコメントアウト：

```bash
# 無効にしたいチェック
# check_npm_packages
check_python_packages
```

### カスタムチェックを追加

```bash
# check_supply_chain_unix.sh に以下を追加

check_custom_security_setting() {
  SECTION_START "Custom Security Check"

  # カスタム検証ロジック
  if [[条件 ]]; then
    PASS_CHECK "説明"
  else
    FAIL_CHECK "説明"
  fi

  SECTION_END
}

# メインループに追加
# check_custom_security_setting
```

---

## 📝 トラブルシューティング

### PowerShell: "実行ポリシー" エラー

```powershell
# 一時的に実行許可
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# 実行
.\check-supply-chain-windows.ps1
```

### Bash: Permission denied

```bash
chmod +x check-supply-chain-unix.sh
./check-supply-chain-unix.sh
```

### Raspberry Pi: メモリ不足

```bash
# 軽量版実行（一部チェックを簡略化）
export LIGHTWEIGHT_MODE=1
./check-supply-chain-rpi.sh
```

---

## 🔐 推奨される運用方法

### 定期実行スケジュール

1. **初回**: フルスキャン (全チェック項目)
2. **週1回**: セキュリティチェック (上位5項目)
3. **月1回**: 詳細監査 (全項目+カスタムチェック)

### 自動化例

#### Linux cron

```bash
# /etc/cron.d/supply-chain-check
0 2 * * 0 /path/to/check-supply-chain-unix.sh >> /var/log/security-check.log 2>&1
```

#### Windows Task Scheduler

```powershell
$action = New-ScheduledTaskAction -Execute "powershell" -Argument "-File C:\Scripts\check-supply-chain-windows.ps1"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Supply Chain Security Check"
```

---

## 📚 詳細実装ガイド

詳しい実装方法は [`docs/IMPLEMENTATION_GUIDE.md`](docs/IMPLEMENTATION_GUIDE.md) を参照してください。

---

## ⚖️ ライセンス

MIT License

---

## 🙋 FAQ

### Q: Sudoは必要ですか？

**A**: オプションです。Sudoなしで基本的なチェックは実行できます。
- ネットワークチェックなど一部チェック項目はsudo推奨
- Raspberry PiではSudo不要の軽量版で問題ありません

### Q: 実行時間はどのくらい？

**A**: 環境による:
- 通常PC: 2-5分
- Raspberry Pi: 5-15分
- ネットワークスキャン有効時: +3-5分

### Q: レポートを自動送信できますか？

**A**: はい。スクリプト出力をメール転送可能:
```bash
./check-supply-chain-unix.sh | mail -s "Security Report" admin@example.com
```

### Q: オフラインで実行できますか？

**A**: はい。ネットワーク依存チェック以外は完全にオフライン実行可能です。

---

## 🐛 既知の制限事項

1. **Virtual Machine環境**: システムコール制限により一部チェックが制限される
2. **Docker コンテナ内**: ホストシステムの可視性が限定される
3. **SELinux有効環境**: 追加の権限が必要な場合がある

---

## 🤝 フィードバック・改善提案

このツールを改善するご提案があれば、以下をご確認ください：

- チェック項目の追加要望
- 新しい攻撃ベクトルへの対応
- パフォーマンス最適化提案

---

## 参考資料

- [NIST Supply Chain Risk Management](https://csrc.nist.gov/publications/detail/sp/800-53b/final)
- [OWASP Security Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)

---

**最終更新**: 2026年4月
**バージョン**: 1.0.0
