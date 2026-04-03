# 貢献ガイド
## Contributing to Supply Chain Security Check Tool

このプロジェクトへの貢献をありがとうございます！ 

---

## 📋 目次

1. [貢献のしかた](#貢献のしかた)
2. [行動規範](#行動規範)
3. [バグ報告](#バグ報告)
4. [機能提案](#機能提案)
5. [コード貢献](#コード貢献)
6. [コード規約](#コード規約)
7. [Pull Request プロセス](#pull-request-プロセス)

---

## 貢献のしかた

### 1. 小さな改善（タイポ、ドキュメント）

```bash
# 直接 PR を作成してください
# Issue 作成は不要
```

### 2. バグ報告

```bash
# Issue を作成
# (テンプレートに従う)
```

### 3. 機能追加

```bash
# 1. Issue を作成して提案
# 2. メンテナーの承認を待つ
# 3. 実装を開始
# 4. PR を作成
```

### 4. 大規模な変更

```bash
# 事前に Discussions で相談してください
```

---

## 行動規範

このプロジェクトの参加者は、以下の行動規範に従うことを約束します：

### 我々は以下を保証します

✅ **尊重と包容性**
- あらゆるバックグラウンドの人を歓迎
- 異なる意見を尊重
- 建設的な対話を重視

✅ **プロフェッショナルな環境**
- ハラスメント・差別なし
- 誠実で正直なコミュニケーション
- 他者の時間を尊重

✅ **コラボレーション重視**
- 相互扶助
- 学習と教育
- チームワーク

### 許容されない行動

❌ ハラスメント・差別的発言
❌ 個人的な攻撃
❌ スパム・無関係な宣伝
❌ プライバシー侵害
❌ その他不適切な行為

**違反報告:** admin@example.com に連絡

---

## バグ報告

### レポートテンプレート

```markdown
## 概要
簡潔なバグの説明

## 環境
- OS: macOS 12.0
- 実行環境: Python 3.9
- スクリプト: check-supply-chain-unix.sh v1.0

## 再現手順
1. ...
2. ...
3. ...

## 期待される動作
詳細に説明

## 実際の動作
エラーメッセージやスクリーンショット

## ログ
```
supply_chain_check_report_*.txt の内容
```
```

### バグ報告のチェックリスト

- [ ] 最新版を確認した
- [ ] 既存の Issue で報告されていない
- [ ] 詳細な再現手順を含めた
- [ ] エラーメッセージ全文を記載した
- [ ] OS/バージョン情報を含めた

---

## 機能提案

### テンプレート

```markdown
## 機能説明
新機能を簡潔に説明

## ユースケース
何のために必要か、どのように役立つか

## 仕様
### チェック項目
- チェック内容 A
- チェック内容 B

### 実装方法
- 言語: Bash / PowerShell
- ファイル: check-supply-chain-*.sh
- 依存コマンド: git, npm

### 出力例
```
✓ PASS: New security check passed
```

## その他
参考資料やリンク
```

---

## コード貢献

### セットアップ

```bash
# 1. リポジトリをフォーク
# GitHub Web UI から

# 2. クローン
git clone https://github.com/YOUR_USERNAME/repo.git
cd repo

# 3. upstream を追加
git remote add upstream https://github.com/ORIGINAL_OWNER/repo.git

# 4. ブランチを作成
git checkout -b feature/your-feature
```

### ローカルテスト

```bash
# Bash スクリプト
bash -n check-supply-chain-unix.sh  # 構文チェック
./check-supply-chain-unix.sh        # 実行テスト

# PowerShell スクリプト
pwsh -NoProfile -Command {
    Test-Path .\check-supply-chain-windows.ps1
}
.\check-supply-chain-windows.ps1    # 実行テスト

# ShellCheck でコード品質確認
shellcheck check-supply-chain-unix.sh
```

---

## コード規約

### Bash スクリプト

```bash
#!/bin/bash

# ============================================================================
# 説明: スクリプトの目的
# ============================================================================

set -o pipefail  # パイプ内のエラーを検出

# ============================================================================
# 変数定義
# ============================================================================

# 定数: 大文字_スネークケース
REPORT_FILE="report_$(date +%s).txt"
MAX_RETRIES=3

# 関数内変数: local キーワード付き
function_name() {
    local local_var="value"
}

# ============================================================================
# 関数定義
# ============================================================================

# 関数名: 小文字_スネークケース
check_ssh_security() {
    # インデント: スペース 4個
    local ssh_dir="$HOME/.ssh"
    
    if [ -d "$ssh_dir" ]; then
        echo "✓ SSH directory exists"
    else
        echo "✗ SSH directory not found"
    fi
}

# ============================================================================
# メイン処理
# ============================================================================

main() {
    check_ssh_security
}

main "$@"
```

**ガイドライン:**
- インデント: スペース 4個
- 変数は引用符で囲む: `"$var"` (not `$var`)
- 明示的なエラーチェック: `set -e` または `|| exit 1`
- コメント: 日本語 OK、簡潔に

### PowerShell スクリプト

```powershell
<#
.SYNOPSIS
    スクリプトの概要

.DESCRIPTION
    詳細説明

.PARAMETER Verbose
    詳細出力を有効化

.EXAMPLE
    .\check-supply-chain-windows.ps1 -Verbose
#>

param(
    [switch]$Verbose = $false
)

# ============================================================================
# 定数・変数
# ============================================================================

$REPORT_FILE = "report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$MAX_RETRIES = 3

# ============================================================================
# 関数定義
# ============================================================================

function Check-SSHSecurity {
    <#
    .SYNOPSIS
        SSH設定をチェック
    #>
    
    # インデント: スペース 4個
    $sshPath = Join-Path $HOME ".ssh"
    
    if (Test-Path $sshPath) {
        Write-Host "✓ SSH directory exists" -ForegroundColor Green
    } else {
        Write-Host "✗ SSH directory not found" -ForegroundColor Red
    }
}

# ============================================================================
# メイン処理
# ============================================================================

function Main {
    Check-SSHSecurity
}

Main
```

**ガイドライン:**
- インデント: スペース 4個
- 関数: PascalCase (`Check-SSHSecurity`)
- 変数: camelCase (`$sshPath`)
- 型指定推奨: `[string]$path`

### ドキュメント

```markdown
# タイトル

説明文。段落は明確に区切る。

## セクション

- 箇条書きで簡潔に
- 1行は80文字目安

### サブセクション

詳細説明。

```bash
# コード例
echo "example"
```

## 関連リンク

- [参考資料](https://example.com)
```

**ガイドライン:**
- マークダウン形式
- 日本語 OK
- 外部リンク多めに
- コード例を含める

---

## Pull Request プロセス

### 1. PR 作成前

- [ ] fork & clone
- [ ] 新しいブランチを作成: `git checkout -b feature/xxx`
- [ ] 変更を実装
- [ ] ローカルでテスト
- [ ] コミット署名推奨: `git commit -S -m "..."`

### 2. PR 作成

```bash
# リモートにプッシュ
git push origin feature/xxx

# GitHub Web UI で PR を作成
# (テンプレートに従う)
```

### PR テンプレート

```markdown
## 説明
変更内容を簡潔に説明してください

## 関連Issue
Closes #123

## 変更の種類
- [ ] バグ修正
- [ ] 新機能
- [ ] ドキュメント更新
- [ ] パフォーマンス改善
- [ ] リファクタリング

## テスト方法
変更をテストした方法を説明

## テスト環境
- OS: macOS 12.0
- PowerShell: 7.0
- Bash: 5.1

## チェックリスト
- [ ] コードレビュー済み
- [ ] テスト実施済み
- [ ] ドキュメント更新済み
- [ ] コミット署名あり
- [ ] 関連Issue リンク済み
```

### 3. レビュープロセス

- メンテナーがレビュー実施
- 変更要求時は対応
- CI チェック合格
- マージ（通常 squash merge）

### 4. マージ後

```bash
# ローカルのブランチを削除
git branch -d feature/xxx

# リモートの同期
git fetch --prune
git pull upstream main
```

---

## コミットメッセージ規約

### フォーマット

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type（タイプ）

| Type | 説明 | 例 |
|------|------|-----|
| `feat` | 新機能 | `feat(rpi): Add GPU temperature check` |
| `fix` | バグ修正 | `fix(ssh): Correct permission check` |
| `docs` | ドキュメント | `docs: Update README` |
| `style` | コード整形（意味なし） | `style: Reformat code` |
| `refactor` | コード改善 | `refactor: Simplify logic` |
| `perf` | パフォーマンス | `perf: Optimize file scan` |
| `test` | テスト追加 | `test: Add SSH check test` |
| `chore` | その他 | `chore: Update dependencies` |

### 例

```
feat(unix): Add cron job auditing

- Implement cron job detection
- Check for suspicious commands
- Add to system monitoring section

Closes #42
Co-Authored-By: Jane Doe <jane@example.com>
```

---

## サポート

### 質問がある場合

1. ドキュメントを確認
2. 既存の Issue/Discussions 検索
3. 新規 Discussion を開く
4. メール: admin@example.com

### セキュリティ問題

🔒 **秘密にレポート:** admin@example.com に連絡
（GitHub Issues には公開しないこと）

---

## ライセンス

このプロジェクトに貢献することで、あなたの貢献は MIT ライセンス下でライセンスされることに同意します。

---

## 謝辞

貢献をありがとうございました！ 🙏

あなたの貢献がこのプロジェクトをより良くしてくれます。

**貢献者一覧:**
- [Contributors on GitHub](../../contributors)

