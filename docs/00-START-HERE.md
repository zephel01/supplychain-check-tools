# 🔐 Supply Chain Security Check Tool
## サプライチェーン攻撃防止ツール - スタートガイド

---

## 📦 このツールセットについて

サプライチェーン攻撃（パッケージ汚染、開発環境侵害など）から保護するための **包括的なセキュリティ監査ツール** です。

複数のプラットフォームに対応し、自動化されたセキュリティチェックを実行します。

---

## 🎯 どのファイルから始める？

### 1️⃣ **初めての方**
→ **[QUICKSTART.md](QUICKSTART.md)** (5分で実行可能)

### 2️⃣ **詳しく理解したい**
→ **[../README.md](../README.md)** (完全なドキュメント)

### 3️⃣ **カスタマイズしたい**
→ **[IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)** (実装詳細)

---

## 🚀 あなたのOS別ガイド

### Windows ユーザー
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\check-supply-chain-windows.ps1
```
👉 [詳細はREADMEを参照](../README.md#windows)

### macOS / Linux ユーザー
```bash
chmod +x check-supply-chain-unix.sh
./check-supply-chain-unix.sh
```
👉 [詳細はREADMEを参照](../README.md#macos--linux)

### Raspberry Pi OS ユーザー
```bash
chmod +x check-supply-chain-rpi.sh
./check-supply-chain-rpi.sh
```
👉 [詳細はREADMEを参照](../README.md#raspberry-pi-os)

---

## 📋 チェック項目 (全12項目)

| # | カテゴリ | 内容 |
|----|---------|------|
| 1️⃣ | コード署名 | Authenticode/codesign/GnuPG検証 |
| 2️⃣ | パッケージ管理 | npm/pip/Gems/Cargo整合性確認 |
| 3️⃣ | Git設定 | 署名、Hooks、危険なalias検出 |
| 4️⃣ | SSH セキュリティ | 鍵パーミッション、known_hosts確認 |
| 5️⃣ | 環境変数 | 機密情報露出検出 |
| 6️⃣ | ファイアウォール | Windows/macOS/Linux設定確認 |
| 7️⃣ | ネットワーク | リスニングポート、接続監視 |
| 8️⃣ | ファイル権限 | パーミッション異常検出 |
| 9️⃣ | プロセス監視 | 疑わしいプロセス検出 |
| 🔟 | Cron jobs | 自動実行タスク監査 |
| 1️⃣1️⃣ | (Windows) 署名更新 | Windows Update確認 |
| 1️⃣2️⃣ | (RPi) 温度監視 | CPU/GPU温度確認 |

---

## 📊 レポート例

```
SUPPLY CHAIN SECURITY CHECK SUMMARY
=====================================
✓ Passed:  18
✗ Failed:  2
⚠ Warned:  3
ℹ Infos:   8

Total: 31 checks completed
Report: supply_chain_check_report_20260403_143022.txt
```

---

## ✅ 次のステップ

### 初回実行後

1. **レポート確認** - 問題点を確認
2. **優先度付け** - FAILと警告から対応
3. **改善実施** - パッケージ更新など

### 定期運用

```bash
# 毎週日曜 午前2時に実行
0 2 * * 0 /path/to/check-supply-chain-unix.sh
```

---

## 📚 ドキュメント構成

```
📄 00-START-HERE.md          ← 今ここ！
📄 QUICKSTART.md              ← 5分クイックガイド
📄 README.md                  ← 完全なドキュメント
📄 IMPLEMENTATION_GUIDE.md    ← 技術詳細・カスタマイズ

🔧 check-supply-chain-windows.ps1   ← Windows
🔧 check-supply-chain-unix.sh       ← macOS/Linux
🔧 check-supply-chain-rpi.sh        ← Raspberry Pi
```

---

## 🔗 リンク集

| リソース | URL |
|---------|-----|
| NIST Supply Chain | https://csrc.nist.gov/publications/detail/sp/800-53b/final |
| OWASP Top 10 | https://owasp.org/Top10/ |
| CIS Benchmarks | https://www.cisecurity.org/cis-benchmarks/ |

---

## ❓ よくある質問

**Q: Sudoは必要ですか？**
A: 基本的なチェックはなしで実行可能。ネットワークチェックはあると便利。

**Q: 実行時間は？**
A: 通常PC: 2-5分、Raspberry Pi: 5-15分

**Q: オフラインで実行できますか？**
A: はい、ネットワーク依存チェック以外は完全オフライン実行可能

**Q: レポートは暗号化できますか？**
A: はい、GnuPGで暗号化推奨 → `gpg --symmetric report.txt`

---

## 🎬 それでは、始めましょう！

### 👉 次は [QUICKSTART.md](QUICKSTART.md) へ

---

**バージョン**: 1.0.0 | **ライセンス**: MIT | **最終更新**: 2026年4月
