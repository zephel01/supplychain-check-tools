# Git 設定ガイド
## .gitignore、.gitattributes、その他の設定ファイル解説

---

## 📋 目次

1. [.gitignore の詳細](#gitignore-の詳細)
2. [.gitattributes の設定](#gitattributes-の設定)
3. [LICENSE ファイル](#license-ファイル)
4. [CONTRIBUTING.md](#contributingmd)
5. [GIT_WORKFLOW.md](#git_workflowmd)

---

## .gitignore の詳細

### 概要

`.gitignore` は、Git リポジトリから除外したいファイルやディレクトリを指定するファイルです。

**このプロジェクトでは以下を除外：**

### 1. 生成レポートファイル

```gitignore
supply_chain_check_report_*.txt
*.log
security_check_*.log
debug.log
```

**理由:**
- スクリプト実行時に自動生成されるファイル
- 個人環境固有の結果
- バージョン管理の対象外

**例:**
```
supply_chain_check_report_20260403_143022.txt  ❌ 除外
supply_chain_check_report_20260410_090000.txt  ❌ 除外
debug.log                                      ❌ 除外
```

### 2. 認証情報・秘密情報

```gitignore
.env
.env.local
.env.*.local
*.key
*.pem
*.p8
secrets.txt
credentials.json
api_keys.json
```

**理由:**
- 🔴 **セキュリティ上、絶対にコミットしてはいけない**
- GitHub に誤って公開されると、攻撃の対象になる
- API キーやパスワードの漏洩につながる

**危険な例（除外されるべき）:**
```bash
DATABASE_URL=postgresql://user:password@localhost
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
API_KEY=sk_live_xxxxxxxxxxxxxxxx
```

**安全な方法:**
```bash
# ✅ .env.example を作成し、テンプレートのみコミット
DATABASE_URL=postgresql://user:password@localhost
# ↓
DATABASE_URL=postgresql://localhost/database_name

# ✅ GitHub Secrets で管理
# または
# ✅ 環境変数ファイルは .gitignore で除外
```

### 3. SSH・GPG鍵

```gitignore
id_rsa
id_rsa.pub
id_ed25519
id_ed25519.pub
known_hosts
~/.gnupg/*
```

**理由:**
- 秘密鍵は絶対に公開してはいけない
- 公開鍵でさえ、フィンガープリント情報など注意が必要

**チェック方法:**
```bash
# 誤ってコミットされた秘密鍵を検出
git log --all --full-history -- id_rsa

# 削除する場合
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch id_rsa' HEAD
```

### 4. OS固有ファイル

```gitignore
# macOS
.DS_Store
.AppleDouble
.LSOverride
._*
.Spotlight-V100
.Trashes

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/

# Linux
.directory
.Trash-*
```

**理由:**
- OS が自動生成するメタデータ
- 開発環境に不要
- クロスプラットフォーム開発で競合の原因に

**例:**
```
.DS_Store       (macOS のファイル属性キャッシュ)
Thumbs.db       (Windows のサムネイルキャッシュ)
.Spotlight-V100 (macOS の検索インデックス)
```

### 5. IDE・エディタ設定

```gitignore
# VS Code
.vscode/
.vscode/settings.json
*.code-workspace

# JetBrains
.idea/
*.iml

# Sublime Text
*.sublime-project
*.sublime-workspace

# Vim
.vim/
*~
```

**理由:**
- IDE設定は個人に依存
- チームメンバーで異なる可能性
- 自動生成される設定ファイル

**推奨:**
- 共有したい設定は `.editorconfig` を使用
- IDE設定は個人の `.gitconfig` で管理

### 6. 依存パッケージ

```gitignore
node_modules/
venv/
ENV/
vendor/
```

**理由:**
- `package.json`, `requirements.txt` で管理可能
- ファイルサイズが巨大（数百MB〜GB）
- Git が遅くなる

**チェック方法:**
```bash
# lock ファイルは含める（推奨）
git add package-lock.json      # ✅ 含める
# git add node_modules/         # ❌ 除外

# インストール方法
npm ci  # lock ファイルに基づいて正確にインストール
```

### 7. ビルド・キャッシュ

```gitignore
build/
dist/
.cache/
*.o
*.a
*.so
```

**理由:**
- ビルド結果は再現可能
- ソースコードから再生成可能
- バージョン管理の対象外

### 8. ドキュメント管理

#### 📝 docs/inside/ ディレクトリについて

`docs/inside/` ディレクトリには、note.com 向けの記事ファイルが格納されています：

```
docs/inside/
├── NOTE_ARTICLE.md               ✅ コミット対象（Markdown形式）
└── NOTE_ARTICLE_PLAINTEXT.txt    ✅ コミット対象（プレーンテキスト形式）
```

**Git管理方針:**
- ✅ **コミット対象**: 重要な公式ドキュメント
- 理由: 複数の形式（Markdown / プレーンテキスト）を提供し、様々なプラットフォームでの公開を支援
- ブログやドキュメントサイトへの公開が目的

**含める理由:**
- リポジトリのドキュメント資産
- note.com や他の執筆プラットフォームへの公開用
- バージョン管理による更新履歴の記録

**参考：** [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) に詳細説明あり

---

## .gitattributes の設定

### 概要

`.gitattributes` は、ファイルタイプごとに Git の動作を指定するファイルです。

### 推奨設定

```gitattributes
# ============================================================================
# Line Endings (改行コード)
# ============================================================================

# Unix形式（LF）で統一するファイル
*.sh text eol=lf
*.bash text eol=lf
*.ps1 text eol=crlf
*.bat text eol=crlf
*.cmd text eol=crlf

# テキストファイル
*.md text eol=lf
*.txt text eol=lf
*.json text eol=lf
*.yaml text eol=lf
*.yml text eol=lf

# ============================================================================
# バイナリファイル
# ============================================================================
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.pdf binary
*.zip binary
*.tar binary
*.gz binary

# ============================================================================
# Diff表示
# ============================================================================
*.md diff=markdown
*.json diff=json

# ============================================================================
# Merge戦略
# ============================================================================
Gemfile.lock merge=union
package-lock.json merge=union
```

### 設定方法

```bash
# リポジトリルートに .gitattributes を作成
cat > .gitattributes << 'EOF'
*.sh text eol=lf
*.md text eol=lf
*.json text eol=lf
EOF

# コミット
git add .gitattributes
git commit -m "Add .gitattributes for consistent line endings"
```

### Windows での改行コード問題

**問題：**
- Windows は CRLF（\r\n）を使用
- Unix/macOS は LF（\n）を使用
- Git で競合が発生

**解決方法:**

```bash
# グローバル設定
git config --global core.safecrlf true
git config --global core.autocrlf true  # 推奨

# プロジェクト別設定
git config core.safecrlf true
git config core.autocrlf input  # Unix/Linux の場合
git config core.autocrlf true   # Windows の場合
```

---

## LICENSE ファイル

### MIT ライセンス（このプロジェクト用）

```
MIT License

Copyright (c) 2026 Supply Chain Security Check Tool Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### ライセンスの種類比較

| ライセンス | 商用利用 | 改変 | 配布 | 公開義務 | 適用場面 |
|-----------|---------|------|------|---------|---------|
| **MIT** | ✅ | ✅ | ✅ | ❌ | 最も自由（このプロジェクト） |
| **Apache 2.0** | ✅ | ✅ | ✅ | ⚠️ | 特許条項あり |
| **GPL v3** | ✅ | ✅ | ✅ | ✅ | コピーレフト型（厳格） |
| **ISC** | ✅ | ✅ | ✅ | ❌ | MIT と同等 |

---

## CONTRIBUTING.md

### テンプレート例

```markdown
# 貢献ガイド

このプロジェクトへの貢献をありがとうございます！

## 貢献方法

### 1. バグ報告

以下の情報を含めてください：
- 再現手順
- 期待される動作
- 実際の動作
- OS・バージョン情報

### 2. 機能追加

1. Issue を開いて提案を討論
2. Fork してブランチを作成
3. コミット（署名付き推奨）
4. Pull Request を作成

### 3. ドキュメント改善

- タイポ修正
- 説明の明確化
- 例の追加

## コードスタイル

### Shell Script (Bash)

```bash
# 変数名は大文字のスネークケース
CHECK_PASSED=0

# 関数名は小文字のスネークケース
check_ssh_security() {
    # インデント: スペース 4個
}

# コメント: 日本語 OK
# SSH鍵の権限確認
```

### PowerShell

```powershell
# 関数名: PascalCase
function Check-SSHSecurity {
    # インデント: スペース 4個
}

# 変数名: camelCase
$checksPassed = 0
```

## コミットメッセージ

```
タイプ: 簡潔な説明

詳細説明（オプション）

関連Issue: #123
```

**タイプ:**
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント
- `refactor`: コード改善
- `test`: テスト
- `chore`: その他

**例:**
```
feat: Add GPU temperature check for Raspberry Pi

- Added vcgencmd integration
- Implemented temperature threshold alerts
- Added to system info section

Fixes #42
```

## Pull Request

### 作成前のチェック

- [ ] ブランチは最新の main から作成
- [ ] コミット署名あり（推奨）
- [ ] テスト/実行確認済み
- [ ] ドキュメント更新済み

### PR テンプレート

```markdown
## 説明
変更内容を簡潔に説明

## 関連Issue
Closes #123

## テスト方法
どのようにテストしたか

## チェックリスト
- [ ] コード確認済み
- [ ] ドキュメント更新済み
- [ ] テスト実行済み
```

## 行動規範

このプロジェクトは以下の方針に従います：
- 尊重と包容性
- 建設的なコミュニケーション
- ハラスメント・差別の禁止
```

---

## GIT_WORKFLOW.md

### 推奨されるワークフロー

#### 1. リポジトリのセットアップ

```bash
# リポジトリを初期化
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"

# コミット署名の有効化（推奨）
git config commit.gpgsign true
git config user.signingkey <your-key-id>
```

#### 2. ブランチ戦略（Git Flow）

```
main（本番）
  ├── release/1.0.0
  └── hotfix/bug-xxx
develop（開発）
  ├── feature/add-new-check
  ├── feature/improve-docs
  └── bugfix/fix-ssh-check
```

**コマンド例:**

```bash
# フィーチャーブランチを作成
git checkout -b feature/add-gpu-check develop

# 作業完了後、develop にマージ
git checkout develop
git merge --no-ff feature/add-gpu-check

# ブランチ削除
git branch -d feature/add-gpu-check
```

#### 3. コミットのベストプラクティス

```bash
# 小分けにコミット（atomicity）
git add check_function.sh
git commit -m "feat: Add SSH security check function"

git add docs.md
git commit -m "docs: Update SSH security documentation"

# 署名付きコミット
git commit -S -m "feat: Implement new security check"

# コミット履歴確認
git log --oneline --graph --all
```

#### 4. Pull Request ベースのワークフロー

```bash
# 1. Fork してクローン
git clone https://github.com/your-fork/repo.git
cd repo

# 2. フィーチャーブランチを作成
git checkout -b feature/new-feature

# 3. コミット（署名付き推奨）
git commit -S -m "feat: Add new feature"

# 4. 自分のフォークにプッシュ
git push origin feature/new-feature

# 5. GitHub で Pull Request を作成
# （Web UI から）
```

#### 5. マージ戦略

```bash
# Fast-forward マージ（履歴が一直線）
git merge feature/xxx

# Merge commit を強制（履歴に残す）
git merge --no-ff feature/xxx

# Squash マージ（コミットを1つに）
git merge --squash feature/xxx
git commit -m "feat: Implement feature xxx"

# Rebase マージ（履歴を整理）
git rebase feature/xxx
```

#### 6. 共同開発時の注意点

```bash
# プッシュ前に常に pull
git pull origin main

# 競合解決
git merge --no-edit  # または対話的に解決

# リモート削除ブランチの同期
git fetch --prune

# 新しいブランチをリモート追跡
git branch -u origin/feature/xxx
```

---

## セキュリティチェック

### 機密情報の誤公開防止

```bash
# Git pre-commit フック例
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# 機密情報をチェック
if git diff --cached | grep -E "password|api_key|token|secret"; then
    echo "❌ 機密情報が含まれています"
    exit 1
fi
EOF

chmod +x .git/hooks/pre-commit
```

### 誤ってプッシュした場合の対処

```bash
# 誤ったコミットを確認
git log --all --full-history -- sensitive_file.key

# BFG Repo-Cleaner を使用（推奨）
bfg --delete-files sensitive_file.key

# または git filter-branch
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch sensitive_file.key' \
  --prune-empty --tag-name-filter cat -- --all

# 強制プッシュ（注意！）
git push origin --force --all
```

---

## トラブルシューティング

### .gitignore が効かない場合

```bash
# キャッシュをクリア
git rm -r --cached .
git add -A
git commit -m "chore: Update gitignore"
```

### 改行コード問題

```bash
# LF に統一
git config core.safecrlf false
find . -name "*.sh" -exec dos2unix {} \;
git add -A
git commit -m "fix: Normalize line endings to LF"
```

### Large File の処理

```bash
# Git LFS を使用
git lfs install
git lfs track "*.iso"
git add .gitattributes
git commit -m "chore: Configure Git LFS"
```

---

**参考資料:**
- [Git 公式ドキュメント](https://git-scm.com/doc)
- [GitHub ガイド](https://docs.github.com)
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)

