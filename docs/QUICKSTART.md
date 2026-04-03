# クイックスタートガイド
## Supply Chain Security Check Tool

---

## 🚀 5分でスタート

### Windows

```powershell
# 1. PowerShellを開く (管理者推奨)
# 2. スクリプトをダウンロード
# 3. 実行ポリシーを一時的に変更
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# 4. スクリプト実行
.\check-supply-chain-windows.ps1

# 5. レポート確認
notepad supply_chain_check_report_*.txt
```

### macOS / Linux

```bash
# 1. ターミナルを開く
# 2. スクリプトをダウンロード

# 3. 実行権限付与
chmod +x check-supply-chain-unix.sh

# 4. スクリプト実行
./check-supply-chain-unix.sh

# 5. レポート確認
cat supply_chain_check_report_*.txt
```

### Raspberry Pi OS

```bash
# 1. SSHでログイン
ssh pi@raspberry-pi-ip

# 2. スクリプトをダウンロード

# 3. 実行権限付与
chmod +x check-supply-chain-rpi.sh

# 4. スクリプト実行 (軽量モード)
./check-supply-chain-rpi.sh

# 5. レポート確認
cat supply_chain_check_report_*.txt
```

---

## 📊 レポート解釈

### 出力例

```
✓ PASS: npm audit: No vulnerabilities detected
✗ FAIL: Found 3 unauthorized git aliases
⚠ WARN: SSH key permissions: 644 (should be 600)
ℹ INFO: Python version: 3.9.10
```

### 優先度別対応

| マーク | 意味 | 対応時期 |
|--------|------|---------|
| ✓ PASS | 要件満たしている | なし |
| ⚠ WARN | 注意が必要 | 週内 |
| ✗ FAIL | 即座の対応必要 | 今日中 |
| ℹ INFO | 参考情報 | 記録 |

---

## 🔧 よくある対応方法

### npm 脆弱性修正
```bash
npm audit fix
npm audit fix --force
```

### SSH鍵パーミッション修正
```bash
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 700 ~/.ssh
```

### Git署名有効化
```bash
git config --global commit.gpgsign true
git config --global user.signingkey <your-key-id>
```

### Python仮想環境
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

---

## 📅 定期スケジュール

```bash
# 週次実行
0 2 * * 0 /path/to/check-supply-chain-unix.sh

# 月次実行
0 2 1 * * /path/to/check-supply-chain-unix.sh
```

---

## 📞 トラブル時

```bash
# エラーメッセージ確認
cat supply_chain_check_report_*.txt | tail -20

# 実行ログ確認
./check-supply-chain-unix.sh 2>&1 | tee debug.log

# 詳細は IMPLEMENTATION_GUIDE.md を参照
```

---

**詳細は README.md と IMPLEMENTATION_GUIDE.md を参照してください。**
