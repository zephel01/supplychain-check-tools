# プロジェクト構成ガイド
## Project Structure Overview

このドキュメントは、プロジェクトの全ファイル構成と各ファイルの役割を説明します。

---

## 📁 ディレクトリ構成

```
supplychain-check-tools/
│
├── 📍 スタートガイド
│   ├── 00-START-HERE.md          ⭐ 最初に読むファイル
│   ├── QUICKSTART.md              5分で実行するガイド
│   └── README.md                  完全なドキュメント
│
├── 📚 ドキュメント
│   ├── IMPLEMENTATION_GUIDE.md    技術詳細・カスタマイズ
│   ├── GIT_CONFIG_GUIDE.md        Git設定の詳細説明
│   ├── PROJECT_STRUCTURE.md       このファイル
│   ├── CONTRIBUTING.md            貢献ガイド
│   └── LICENSE                    MIT ライセンス
│
├── 🔧 セキュリティチェックスクリプト
│   ├── check-supply-chain-windows.ps1  Windows用 (PowerShell)
│   ├── check-supply-chain-unix.sh      macOS/Linux用 (Bash)
│   └── check-supply-chain-rpi.sh       Raspberry Pi用 (最適化版)
│
├── ⚙️ セットアップ・設定
│   ├── SETUP_GIT.sh               Git初期化スクリプト
│   ├── .gitignore                 Git除外設定
│   ├── .gitattributes             Git属性設定
│   └── .editorconfig              エディタ設定 (オプション)
│
└── 📊 出力ファイル (実行時に生成)
    └── supply_chain_check_report_YYYYMMDD_HHMMSS.txt
```

---

## 📄 各ファイルの説明

### スタートガイド

#### **00-START-HERE.md** ⭐
- **目的**: 初めてのユーザー向けエントリーポイント
- **内容**: 
  - ツールセットの概要
  - OS別の実行方法
  - チェック項目一覧
  - よくある質問
- **読むべき人**: 全員（最初）

#### **QUICKSTART.md**
- **目的**: 5分で動作確認
- **内容**:
  - 最小限の実行手順
  - OS別コマンド
  - レポート解釈
  - よくある対応方法
- **読むべき人**: 急いでいる人

#### **README.md**
- **目的**: 完全なドキュメント
- **内容**:
  - 機能の詳細説明
  - チェック項目の詳細
  - FAQ
  - 参考資料
  - カスタマイズ方法
- **読むべき人**: 深く理解したい人

### 技術ドキュメント

#### **IMPLEMENTATION_GUIDE.md**
- **目的**: 実装の詳細説明とカスタマイズ
- **内容**:
  - アーキテクチャ概要
  - チェック機構の詳細
  - 各スクリプトの使い方
  - カスタマイズ方法
  - トラブルシューティング
- **読むべき人**: 
  - カスタマイズしたい人
  - 新機能を追加したい人
  - 問題をデバッグしたい人

#### **GIT_CONFIG_GUIDE.md**
- **目的**: Git関連設定ファイルの説明
- **内容**:
  - .gitignore の詳細説明
  - .gitattributes の設定
  - LICENSE について
  - Git ワークフロー
  - セキュリティチェック
- **読むべき人**:
  - Git に不慣れな人
  - プロジェクトを GitHub で共有する人
  - チーム開発する人

#### **CONTRIBUTING.md**
- **目的**: 貢献ガイド
- **内容**:
  - バグ報告方法
  - 機能提案方法
  - コード貢献手順
  - コード規約
  - PR プロセス
- **読むべき人**: 機能追加やバグ報告する人

#### **PROJECT_STRUCTURE.md**
- **目的**: プロジェクト全体の構成説明
- **内容**: 今読んでいるファイル

### セキュリティチェックスクリプト

#### **check-supply-chain-windows.ps1** (474行)
- **言語**: PowerShell 5.0+
- **OS**: Windows
- **実行**: `.\check-supply-chain-windows.ps1`
- **チェック項目**:
  1. Authenticode署名検証
  2. Windows Update確認
  3. ファイアウォール状態
  4. npm パッケージ
  5. Python パッケージ
  6. Git設定
  7. SSH鍵
  8. 環境変数
  9. ネットワーク接続
  10. ファイルシステム権限
- **出力**: `supply_chain_check_report_*.txt`

#### **check-supply-chain-unix.sh** (595行)
- **言語**: Bash 4.0+
- **OS**: macOS, Linux, Ubuntu
- **実行**: `./check-supply-chain-unix.sh`
- **チェック項目**:
  1. codesign/GnuPG署名 (OS別)
  2. GnuPG署名検証
  3. npm パッケージ
  4. Python パッケージ
  5. Git設定
  6. SSH セキュリティ
  7. 環境変数
  8. ファイアウォール
  9. ネットワーク接続
  10. ファイルシステム権限
  11. プロセス監視
  12. Cron ジョブ監査
- **出力**: `supply_chain_check_report_*.txt`

#### **check-supply-chain-rpi.sh** (468行)
- **言語**: Bash 4.0+ (最適化版)
- **OS**: Raspberry Pi OS
- **実行**: `./check-supply-chain-rpi.sh`
- **特徴**:
  - ARM アーキテクチャ最適化
  - 軽量モード対応 (`LIGHTWEIGHT_MODE=1`)
  - GPIO セキュリティチェック
  - CPU/GPU温度監視
  - ブート設定確認
- **チェック項目**: 12項目 (Unix版と同様 + RPi特有)
- **出力**: `supply_chain_check_report_*.txt`

### セットアップ・設定ファイル

#### **SETUP_GIT.sh** (103行)
- **目的**: Git リポジトリの初期化
- **実行**: `./SETUP_GIT.sh`
- **処理**:
  - Git リポジトリ初期化
  - .gitignore 確認
  - 初期コミット作成
  - 次のステップ表示
- **推奨実行**: 最初の1回のみ

#### **.gitignore** (309行)
- **目的**: Git から除外するファイルを指定
- **包含**: 
  - 生成レポート
  - 環境変数ファイル
  - SSH/GPG鍵
  - OS固有ファイル
  - IDE設定
  - 依存パッケージ
  - ビルド・キャッシュ
- **参考**: GIT_CONFIG_GUIDE.md の「.gitignore の詳細」

#### **.gitattributes** (約150行)
- **目的**: ファイル属性を指定 (改行コード、バイナリ判定など)
- **設定**:
  - 改行コード統一 (LF vs CRLF)
  - バイナリ判定
  - Diff/Merge 戦略
  - エンコーディング
- **参考**: GIT_CONFIG_GUIDE.md の「.gitattributes の設定」

#### **LICENSE** (MIT)
- **目的**: ライセンス表記
- **内容**: MIT ライセンステキスト
- **重要**: 必ずリポジトリに含める
- **変更不可**: MIT ライセンス以外にしたい場合は事前相談

#### **.editorconfig** (オプション)
- **目的**: エディタ設定を統一
- **内容例**:
  ```ini
  [*]
  indent_style = space
  indent_size = 4
  end_of_line = lf
  charset = utf-8
  trim_trailing_whitespace = true
  insert_final_newline = true

  [*.{json,yaml,yml}]
  indent_size = 2
  ```
- **推奨**: チーム開発する場合は作成

### 出力ファイル (実行時に生成)

#### **supply_chain_check_report_YYYYMMDD_HHMMSS.txt**
- **生成**: スクリプト実行時
- **内容**:
  - 実行環境情報
  - 各チェック項目の結果
  - 統計情報
  - タイムスタンプ
- **形式**: テキスト (改行コード LF)
- **管理**: .gitignore で除外 (コミット不可)

---

## 📊 ファイル統計

```
総コード/ドキュメント行数:  3,900+ 行
総ファイル数:              13個
合計ファイルサイズ:         ~300KB
実装されたチェック機能:     12項目
対応プラットフォーム:       4種類
ドキュメントページ数:       約50ページ相当
```

---

## 🚀 ファイル使用の流れ

### 初回セットアップ

```
1. 00-START-HERE.md を読む
   ↓
2. QUICKSTART.md で実行
   ↓
3. SETUP_GIT.sh で Git 初期化 (オプション)
   ↓
4. .gitignore、.gitattributes 確認
```

### 通常運用

```
毎回:
  ↓
適切なスクリプトを実行
check-supply-chain-windows.ps1  (Windows)
check-supply-chain-unix.sh      (macOS/Linux)
check-supply-chain-rpi.sh       (Raspberry Pi)
  ↓
supply_chain_check_report_*.txt を確認
  ↓
必要に応じて改善
```

### カスタマイズ

```
IMPLEMENTATION_GUIDE.md を参照
  ↓
スクリプト修正
  ↓
ローカルテスト
  ↓
CONTRIBUTING.md に従い PR 作成 (オプション)
```

---

## 📚 推奨読む順序

### 完全初心者向け

1. **00-START-HERE.md** - 概要把握
2. **QUICKSTART.md** - 最小限の実行
3. **README.md** - 詳細理解

### 開発者向け

1. **README.md** - 機能理解
2. **IMPLEMENTATION_GUIDE.md** - 内部構造
3. **CONTRIBUTING.md** - 貢献方法
4. **GIT_CONFIG_GUIDE.md** - Git管理

### チーム管理者向け

1. **README.md** - 全体把握
2. **GIT_CONFIG_GUIDE.md** - Git設定
3. **CONTRIBUTING.md** - ガイドライン
4. **PROJECT_STRUCTURE.md** - 構成確認

---

## 🔐 セキュリティに関する注意

### 絶対にコミット不可

❌ `.env`, `*.key`, `id_rsa` など
❌ `supply_chain_check_report_*.txt`
❌ 個人情報・認証情報

### Git で管理可能

✅ `.md` ドキュメント
✅ `.sh`, `.ps1` スクリプト
✅ `.gitignore`, `.gitattributes`
✅ `LICENSE`

### 確認方法

```bash
# 誤ってコミットした秘密情報を検出
git log --all --full-history -- id_rsa

# 削除する (必要に応じて)
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch id_rsa' HEAD
```

---

## 🔄 更新・保守方針

### ドキュメント更新

- `README.md`: 機能追加時に更新
- `IMPLEMENTATION_GUIDE.md`: 実装変更時に更新
- `CONTRIBUTING.md`: ガイドライン変更時に更新

### スクリプト更新

- セマンティックバージョニング採用
- `v1.0.0` → `v1.1.0` (機能追加)
- `v1.0.0` → `v1.0.1` (バグ修正)

### リリース時

```bash
git tag -a v1.1.0 -m "Release version 1.1.0"
git push origin v1.1.0
```

---

## 📞 サポート

| 質問 | 参照先 |
|------|--------|
| 使い方がわからない | QUICKSTART.md, README.md |
| バグを報告したい | CONTRIBUTING.md > バグ報告 |
| 機能を追加したい | IMPLEMENTATION_GUIDE.md, CONTRIBUTING.md |
| Git設定がわからない | GIT_CONFIG_GUIDE.md |
| ファイル構成を知りたい | PROJECT_STRUCTURE.md (このファイル) |

---

## 📈 バージョン情報

```
Current Version: 1.0.0
Release Date: 2026-04-03
License: MIT
Maintainers: Supply Chain Security Tool Contributors
```

---

**最後に、貢献を検討している場合は、CONTRIBUTING.md をご覧ください！** 🙏

