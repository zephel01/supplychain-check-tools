# サプライチェーン攻撃防止ツール完全ガイド
## 初心者向け詳細解説 - インストールから実行まで

こんにちは！このガイドでは、サプライチェーン攻撃防止ツール（Supply Chain Security Check Tool）を、全くの初心者でも使えるように、1からていねいに説明します。

---

## 📚 目次

1. [このツールについて](#このツールについて)
2. [準備するもの](#準備するもの)
3. [環境セットアップ](#環境セットアップ)
4. [インストール手順](#インストール手順)
5. [実行方法](#実行方法)
6. [結果の見方](#結果の見方)
7. [よくある質問](#よくある質問)
8. [トラブルシューティング](#トラブルシューティング)

---

## このツールについて

### 🎯 このツールって何？

このツール（Supply Chain Security Check Tool）は、あなたのコンピュータのセキュリティをチェックするための **自動診断ツール** です。

特に以下のような危険から守ります：

- **パッケージ汚染**：ダウンロードしたソフトウェアが改ざんされていないか確認
- **開発環境侵害**：あなたが開発する環境が安全か確認
- **秘密情報漏洩**：パスワードやAPIキーが誤って露出していないか確認

### 🔍 何をチェックするの？

このツールは、以下の **12項目** を自動的にチェックします：

| # | チェック内容 | 例 |
|---|-------------|-----|
| 1 | **コード署名** | ダウンロードしたプログラムが本物か確認 |
| 2 | **パッケージ整合性** | npm/Python パッケージが改ざんされていないか確認 |
| 3 | **Git設定** | プログラムの変更管理が安全に設定されているか確認 |
| 4 | **SSH鍵セキュリティ** | あなたの秘密鍵が安全に保管されているか確認 |
| 5 | **環境変数** | パスワードなどが環境変数に露出していないか確認 |
| 6 | **ファイアウォール** | ファイアウォールが正しく設定されているか確認 |
| 7 | **ネットワーク接続** | 不正な接続がないか確認 |
| 8 | **ファイル権限** | ファイルの権限設定が安全か確認 |
| 9 | **プロセス監視** | 疑わしいプログラムが動作していないか確認 |
| 10 | **定期実行タスク** | 不正な自動実行が設定されていないか確認 |
| 11 | **Windows更新** | Windows Update が最新か確認（Windows のみ） |
| 12 | **温度監視** | CPU温度が正常か確認（Raspberry Pi のみ） |

### ✨ 何が良いのか？

- ✅ **自動実行** - ボタンを押すだけで全チェック実行
- ✅ **複数OS対応** - Windows, macOS, Linux, Raspberry Pi 対応
- ✅ **日本語説明** - 初心者でも理解しやすい
- ✅ **無料・オープンソース** - 自由に使える
- ✅ **レポート自動生成** - 結果がテキストファイルに保存される

---

## 準備するもの

### 必須（絶対必要）

#### 1. **コンピュータ**
- Windows PC（Windows 10以上推奨）
- Mac（Intel / Apple Silicon）
- Linux パソコン
- Raspberry Pi

#### 2. **インターネット接続**
- スクリプトのダウンロード用
- セキュリティチェック用（一部チェックのみ）

#### 3. **ターミナル**
各OSのターミナル（コマンド実行画面）：
- **Windows**: PowerShell または コマンドプロンプト
- **macOS**: ターミナル.app
- **Linux**: 端末（ターミナル）

### 強く推奨（あると便利）

- **Git** - バージョン管理ツール（オプションだが、後でチェックされる）
- **npm/Python** - パッケージマネージャー（既にインストールされている場合は不要）
- **テキストエディタ** - 結果ファイルを開くため（Windows メモ帳でOK）

---

## 環境セットアップ

### ステップ 1️⃣: 何が必要か確認

このツールを実行するには、いくつかの「基本的なプログラム」が必要です。確認してみましょう。

#### Windows の場合

```powershell
# PowerShell のバージョン確認
$PSVersionTable.PSVersion

# 結果例
Major  Minor  Build  Revision
-----  -----  -----  --------
5      1      22000  1

# 5.0 以上なら OK！
```

#### macOS / Linux の場合

```bash
# Bash のバージョン確認
bash --version

# 結果例
GNU bash, version 5.1.8(1)-release (x86_64-apple-darwin20.6.0)
Copyright (C) 2020 Free Software Foundation, Inc.

# 4.0 以上なら OK！
```

### ステップ 2️⃣: Git のインストール（オプション）

Git がインストールされていると、より詳細なチェックが可能です。

#### Windows

```powershell
# Git がインストール済みか確認
git --version

# インストールされていない場合
# → https://git-scm.com/download/win にアクセス
# → ダウンロードして実行
```

#### macOS

```bash
# Git がインストール済みか確認
git --version

# インストールされていない場合
brew install git

# Homebrew がない場合は先にインストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Linux（Ubuntu/Debian）

```bash
# Git がインストール済みか確認
git --version

# インストールされていない場合
sudo apt update
sudo apt install git
```

#### Raspberry Pi OS

```bash
# Git がインストール済みか確認
git --version

# インストールされていない場合
sudo apt update
sudo apt install git
```

### ステップ 3️⃣: Node.js / Python のインストール（オプション）

npm や pip でのパッケージチェックを行いたい場合、これらがあると便利です。

#### Node.js のインストール

**Windows:**
- https://nodejs.org/ にアクセス
- "LTS" バージョンをダウンロード
- インストーラーを実行
- インストール後：
  ```powershell
  node --version
  npm --version
  ```

**macOS:**
```bash
brew install node
```

**Linux/Raspberry Pi:**
```bash
sudo apt update
sudo apt install nodejs npm
```

#### Python のインストール

**Windows:**
- https://www.python.org/downloads/ にアクセス
- 最新バージョンをダウンロード
- インストーラーを実行
- インストール後：
  ```powershell
  python --version
  pip --version
  ```

**macOS:**
```bash
brew install python3
```

**Linux/Raspberry Pi:**
```bash
sudo apt update
sudo apt install python3 python3-pip
```

---

## インストール手順

### ステップ 1️⃣: ツールをダウンロード

#### 方法 A: GitHub から Git Clone（推奨）

最新版を常に入手できます。

**Windows:**
```powershell
# PowerShell を開く（管理者権限推奨）
# 作業フォルダに移動（例：デスクトップ）
cd $HOME\Desktop

# ツールをダウンロード
git clone https://github.com/zephel01/supplychain-check-tools.git
cd supplychain-check-tools

# ダウンロード完了！
```

**macOS / Linux / Raspberry Pi:**
```bash
# ターミナルを開く
# 作業フォルダに移動（例：ホームディレクトリ）
cd ~

# ツールをダウンロード
git clone https://github.com/zephel01/supplychain-check-tools.git
cd supplychain-check-tools

# ダウンロード完了！
```

#### 方法 B: ZIP ファイルでダウンロード

Git がない場合：

1. GitHub の Release ページにアクセス
2. 「Download ZIP」をクリック
3. ダウンロードしたファイルを解凍
4. フォルダを開く

### ステップ 2️⃣: セットアップスクリプトを実行（オプション）

Git リポジトリとして管理したい場合：

**Windows:**
```powershell
# 実行ポリシーを一時的に変更
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# セットアップスクリプトを実行
.\SETUP_GIT.sh
```

**macOS / Linux / Raspberry Pi:**
```bash
# 実行権限を付与
chmod +x SETUP_GIT.sh

# セットアップスクリプトを実行
./SETUP_GIT.sh
```

---

## 実行方法

### Windows での実行

#### Step 1: PowerShell を開く

1. スタートメニューで「PowerShell」を検索
2. 「Windows PowerShell」をクリック
3. または、フォルダ内で `Shift + 右クリック` → 「ここに PowerShell ウィンドウを開く」

#### Step 2: スクリプトを実行

```powershell
# ツールのフォルダに移動（例）
cd C:\Users\YourName\Desktop\supplychain-check-tools

# 実行ポリシーを変更（初回のみ）
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# スクリプトを実行
.\check-supply-chain-windows.ps1

# 実行中...
# ✓ PASS: npm audit: No vulnerabilities detected
# ✗ FAIL: Found 3 unauthorized git aliases
# ...
```

#### Step 3: 結果を確認

```powershell
# 結果ファイルを開く
notepad supply_chain_check_report_*.txt

# または自動的に開く
Invoke-Item supply_chain_check_report_*.txt
```

### macOS / Linux での実行

#### Step 1: ターミナルを開く

- **macOS**: `Command + Space` → 「ターミナル」と入力 → Enter
- **Linux**: アプリケーションメニュー → ターミナル

#### Step 2: 実行権限を付与（初回のみ）

```bash
# ツールのフォルダに移動（例）
cd ~/supplychain-check-tools

# 実行権限を付与
chmod +x check-supply-chain-unix.sh
```

#### Step 3: スクリプトを実行

```bash
# 基本的な実行
./check-supply-chain-unix.sh

# 実行中...
# ✓ PASS: SSH key permissions correct: id_rsa
# ⚠ WARN: SSH key permissions: 644 (should be 600)
# ...
```

#### Step 4: 結果を確認

```bash
# 結果ファイルを表示
cat supply_chain_check_report_*.txt

# またはテキストエディタで開く
open supply_chain_check_report_*.txt  # macOS
nano supply_chain_check_report_*.txt  # Linux
```

### Raspberry Pi での実行

#### Step 1: SSH で接続（リモートからの場合）

```bash
ssh pi@your-raspberry-pi-ip
```

#### Step 2: 実行権限を付与

```bash
cd ~/supplychain-check-tools
chmod +x check-supply-chain-rpi.sh
```

#### Step 3: 軽量モードで実行（推奨）

```bash
# リソース制限に配慮した実行
export LIGHTWEIGHT_MODE=1
./check-supply-chain-rpi.sh
```

#### Step 4: 結果を確認

```bash
cat supply_chain_check_report_*.txt
```

---

## 結果の見方

### 結果ファイルの構造

実行が終わると、以下のような形式のレポートが生成されます：

```
supply_chain_check_report_20260403_143022.txt
```

### 結果の読み方

結果ファイルを開くと、このような内容が表示されます：

```
SUPPLY CHAIN SECURITY CHECK - Windows
=====================================
Started: 2026-04-03 14:30:22

► 1. コード署名検証 (Authenticode)
✓ PASS: Found 20 signed executables
✓ PASS: No unsigned system executables detected

► 2. セキュリティ更新確認
✓ PASS: Windows updates installed: 45
ℹ INFO: Latest update: 2024-01-15

► 3. ファイアウォール設定
✓ PASS: Domain Firewall: ENABLED
✓ PASS: Private Firewall: ENABLED
✓ PASS: Public Firewall: ENABLED

...

================================================================================
SUMMARY
================================================================================
Passed:  18
Failed:  2
Warned:  3
Infos:   8
Total:   31 checks

Timestamp: 2026-04-03 14:35:10
```

### 記号の意味

| 記号 | 意味 | 対応 |
|-----|------|------|
| ✓ **PASS** | チェック合格 | 対応不要 |
| ✗ **FAIL** | チェック失敗 | ⚠️ すぐに対応すべき |
| ⚠️ **WARN** | 警告 | 📝 近いうちに確認 |
| ℹ️ **INFO** | 情報 | 📖 参考情報 |

### 優先度別対応方法

#### 🔴 FAIL（失敗） - すぐに対応

**例:**
```
✗ FAIL: npm audit: Found 5 vulnerabilities
```

**対応方法:**
```bash
# 脆弱性を修正
npm audit fix
npm audit fix --force
```

#### 🟡 WARN（警告） - 近いうちに確認

**例:**
```
⚠ WARN: SSH key permissions: 644 (should be 600)
```

**対応方法:**
```bash
# パーミッションを修正
chmod 600 ~/.ssh/id_rsa
```

#### 🟢 PASS（合格） - 対応不要

```
✓ PASS: Git commit signing enabled
```

---

## よくある質問

### Q1: このツール、安全ですか？

**A:** はい、完全に安全です。

- ✅ **オープンソース** - ソースコードは誰でも見られます
- ✅ **無害** - 何も削除・変更しません、調査するだけです
- ✅ **ローカル実行** - インターネットに情報を送信しません
- ✅ **MIT ライセンス** - 商用利用もOK

### Q2: 実行時間はどのくらい？

**A:** 環境による：
- 通常のPC: **2-5分**
- Raspberry Pi: **5-15分**
- ネットワークスキャン含む場合: **+3-5分**

### Q3: 結果ファイルはどこに保存される？

**A:** スクリプトを実行したフォルダに自動生成：

```
supplychain-check-tools/
└── supply_chain_check_report_20260403_143022.txt
```

### Q4: 定期的に実行したい

**A:** 自動実行を設定できます：

**Windows（Task Scheduler）:**
```powershell
$action = New-ScheduledTaskAction -Execute "powershell" -Argument "-File C:\path\check-supply-chain-windows.ps1"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Supply Chain Check"
```

**macOS/Linux（cron）:**
```bash
# 毎週日曜午前2時に実行
0 2 * * 0 /path/to/check-supply-chain-unix.sh >> /var/log/security-check.log
```

### Q5: Sudo（管理者権限）は必要？

**A:** オプション：
- **なし** - 基本的なチェックは実行可能
- **あり** - より詳しいチェックが可能（推奨）

```bash
# 管理者権限で実行
sudo ./check-supply-chain-unix.sh
```

---

## トラブルシューティング

### 問題 1: PowerShell が実行ポリシーエラーを出す

**エラーメッセージ:**
```
実行ポリシー "Restricted" に違反しています
```

**解決方法:**
```powershell
# 一時的に許可（推奨）
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# その後、スクリプトを実行
.\check-supply-chain-windows.ps1
```

### 問題 2: Permission denied エラー（macOS/Linux）

**エラーメッセージ:**
```bash
bash: ./check-supply-chain-unix.sh: Permission denied
```

**解決方法:**
```bash
# 実行権限を付与
chmod +x check-supply-chain-unix.sh

# その後、スクリプトを実行
./check-supply-chain-unix.sh
```

### 問題 3: コマンドが見つからない

**エラーメッセージ:**
```
npm: command not found
```

**解決方法:**
```bash
# インストール確認
which npm
npm --version

# インストールされていない場合
# Node.js をインストール（前のセクション参照）
```

### 問題 4: Raspberry Pi のメモリ不足

**症状:**
- スクリプトが遅い
- メモリ警告が出る

**解決方法:**
```bash
# 軽量モードで実行
export LIGHTWEIGHT_MODE=1
./check-supply-chain-rpi.sh

# または個別チェックのみ実行
# （全体ではなく、特定のチェック）
```

### 問題 5: 結果ファイルが見つからない

**確認方法:**
```bash
# ファイル一覧表示
ls -la supply_chain_check_report_*.txt

# または検索
find . -name "supply_chain_check_report_*"
```

---

## 次のステップ

### Step 1: 結果を理解する

1. レポートを確認
2. FAIL（失敗）と WARN（警告）を確認
3. 優先度を決める

### Step 2: 問題を修正

各チェック項目ごとの対応方法は、[../docs/README.md](../README.md) を参照してください。

**よくある対応:**

```bash
# npm 脆弱性修正
npm audit fix

# SSH鍵のパーミッション修正
chmod 600 ~/.ssh/id_rsa

# Python 仮想環境作成
python3 -m venv .venv
```

### Step 3: 定期実行を設定

セキュリティは継続的なチェックが重要です：

```bash
# 毎週実行スケジュール設定
# （前のセクション参照）
```

### Step 4: 詳しく学ぶ

- **もっと詳しく知りたい** → [../docs/IMPLEMENTATION_GUIDE.md](../docs/IMPLEMENTATION_GUIDE.md)
- **カスタマイズしたい** → [../docs/IMPLEMENTATION_GUIDE.md](../docs/IMPLEMENTATION_GUIDE.md)
- **チーム開発する** → [../docs/CONTRIBUTING.md](../docs/CONTRIBUTING.md)

---

## 💡 ヒント＆コツ

### 💡 ヒント 1: レポートをバックアップ

```bash
# 定期的にレポートをコピー
cp supply_chain_check_report_*.txt ~/security_reports/

# 変化を追跡できます
```

### 💡 ヒント 2: レポートをメール送信

```bash
# メール送信（Linux）
cat supply_chain_check_report_*.txt | mail -s "Security Report" admin@example.com
```

### 💡 ヒント 3: 環境変数をチェック

```bash
# 危険な環境変数を検出
env | grep -i "password\|token\|key"
```

### 💡 ヒント 4: Git で管理

```bash
# 結果ファイルはコミットしない（.gitignore に含まれる）
git status  # supply_chain_check_report_*.txt は表示されない
```

---

## 📞 サポート・質問

**このガイドでわからないことがあったら:**

1. [よくある質問](#よくある質問) を確認
2. [トラブルシューティング](#トラブルシューティング) を確認
3. [../docs/INDEX.md](../docs/INDEX.md) で他のドキュメントを検索
4. GitHub Issues でサポート受付（今後）

---

## 🎉 まとめ

このガイドに従えば、誰でも簡単に：

✅ ツールをインストール
✅ セキュリティチェックを実行
✅ 結果を理解して対応

できるようになります！

セキュリティは「一度やったら終わり」ではなく、**継続的な監視が大切** です。

このツールを定期実行して、あなたの開発環境を常に安全に保ちましょう！ 🔐

---

**Happy Security Checking! 🚀**

*最終更新: 2026年4月*
*バージョン: 1.0.0*

