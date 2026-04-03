# サプライチェーン攻撃から身を守ろう！
## 自動セキュリティ診断ツール「Supply Chain Security Check Tool」完全ガイド

---

## 📌 この記事について

こんにちは。この記事では、開発環境のセキュリティを自動的にチェックしてくれる無料ツール「**Supply Chain Security Check Tool**」について、完全に解説します。

**この記事を読むと以下がわかります：**

- 🔐 サプライチェーン攻撃って何か？
- 🛡️ なぜセキュリティチェックが必要か？
- 💻 ツールの使い方（初心者向け）
- 🔍 チェック結果の見方と対応方法
- 🚀 今日から始めるセキュリティ対策

**対象者：**
- 開発初心者～中級者
- セキュリティに不安がある人
- 自分のパソコンは安全か心配な人
- 無料のセキュリティツールを探している人

---

## 🎯 目次

1. [サプライチェーン攻撃って何？](#サプライチェーン攻撃って何)
2. [このツールで何ができる？](#このツールで何ができる)
3. [インストール～実行（5分で完了）](#インストール実行5分で完了)
4. [結果の見方と対応](#結果の見方と対応)
5. [よくある質問](#よくある質問)
6. [まとめ](#まとめ)

---

## サプライチェーン攻撃って何？

### 🚨 実例で理解する

2023年に実際に起きた事件：

```
❌ 正規のソフトウェアプロジェクトが乗っ取られる
  ↓
❌ 攻撃者がコードに悪意あるコードを混入
  ↓
❌ 何千万人が知らず知らずのうちに悪質なソフトをダウンロード
  ↓
❌ コンピュータが乗っ取られたり、個人情報が盗まれたり…
```

### 💭 「でも、私は関係ないし…」？

**いいえ、関係あります！**

あなたが開発の仕事をしていれば、以下のようなツールを使っていますよね：

- npm（Node.js のパッケージ）
- pip（Python のパッケージ）
- Ruby Gems
- GitHub のプロジェクト
- Docker イメージ

これらはすべて「サプライチェーン」の一部です。

### 🎯 サプライチェーン攻撃の危険性

| リスク | 具体例 |
|--------|--------|
| **パッケージ汚染** | ダウンロードしたプログラムが改ざんされている |
| **秘密鍵盗難** | あなたの SSH キーが誰かに見られている |
| **認証情報漏洩** | パスワードやトークンがコード内に含まれている |
| **バックドア設置** | 悪質なプログラムがあなたのパソコンに潜んでいる |

これらは「知らないうちに」発生する可能性があります。

### ✅ だから「チェック」が必要

このツールは、これらの危険を **自動的に検出** してくれます。

---

## このツールで何ができる？

### 🔍 12項目の自動セキュリティチェック

このツールを実行するだけで、以下が自動的に確認されます：

#### 1️⃣ **コード署名検証**
> ダウンロードしたプログラムが本物か確認
```
✅ PASS: Found 20 signed binaries
```

#### 2️⃣ **パッケージ依存性チェック**
> npm、pip などで使用しているパッケージが安全か確認
```
✓ npm audit: No vulnerabilities detected
✗ Found 5 high-severity vulnerabilities
```

#### 3️⃣ **Git 設定確認**
> プログラムの変更管理が安全に設定されているか確認
```
✓ Git commit signing enabled
```

#### 4️⃣ **SSH セキュリティ**
> あなたの秘密鍵が安全に保管されているか確認
```
✓ SSH key permissions correct: id_rsa (600)
✗ SSH key permissions: 644 (should be 600)
```

#### 5️⃣ **環境変数チェック**
> パスワードなどが誤って設定されていないか確認
```
✓ No suspicious environment variables detected
```

#### 6️⃣～12️⃣ **その他**
- ファイアウォール状態
- ネットワーク接続
- ファイル権限
- プロセス監視
- Windows セキュリティ更新
- Raspberry Pi 温度監視

### 🎁 すべて無料・オープンソース

```
✅ 無料 - 費用一切なし
✅ MIT ライセンス - 自由に使える
✅ オープンソース - ソースコードが公開されている
✅ 複数 OS 対応 - Windows、Mac、Linux、Raspberry Pi
```

---

## インストール～実行（5分で完了）

### 🖥️ Windows の場合

#### Step 1: PowerShell を開く

1. **スタートメニュー** → 「PowerShell」と検索
2. **Windows PowerShell** をクリック

![PowerShell を開く](イメージ：スタートメニューで PowerShell を検索)

#### Step 2: ツールをダウンロード

```powershell
# ツールをダウンロード
git clone https://github.com/your-username/supplychain-check-tools.git
cd supplychain-check-tools
```

**Git がない場合：**
- https://git-scm.com/download/win
- から Windows 用をダウンロード・インストール

#### Step 3: スクリプトを実行

```powershell
# 実行ポリシーを変更（初回のみ）
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# スクリプト実行
.\check-supply-chain-windows.ps1
```

#### Step 4: 結果を確認

```powershell
# 自動的に結果ファイルが生成される
notepad supply_chain_check_report_*.txt
```

### 🍎 macOS / Linux の場合

#### Step 1: ターミナルを開く

- **macOS**: Command ⌘ + Space → 「ターミナル」
- **Linux**: アプリケーションメニュー → ターミナル

#### Step 2: ツールをダウンロード

```bash
git clone https://github.com/your-username/supplychain-check-tools.git
cd supplychain-check-tools
```

#### Step 3: 実行権限を付与

```bash
chmod +x check-supply-chain-unix.sh
```

#### Step 4: スクリプト実行

```bash
./check-supply-chain-unix.sh
```

#### Step 5: 結果を確認

```bash
cat supply_chain_check_report_*.txt
```

### 🎯 5分後には診断完了！

実行からレポート確認まで、**わずか5分**です。

---

## 結果の見方と対応

### 📊 レポート例

実行後、このような形式のレポートが生成されます：

```
SUPPLY CHAIN SECURITY CHECK
=====================================

► 1. コード署名検証
✓ PASS: Found 20 signed executables

► 2. npm パッケージ検証
✗ FAIL: npm audit: Found 5 vulnerabilities
⚠ WARN: No package-lock.json found

► 3. Git 設定
✓ PASS: Git commit signing enabled

...

================================================================================
SUMMARY
================================================================================
✓ Passed:  15
✗ Failed:  2
⚠ Warned:  3
Total:     20 checks

Timestamp: 2026-04-03 14:35:10
```

### 🎨 記号の意味

| 記号 | 意味 | 対応 |
|-----|------|------|
| ✓ **PASS** | チェック合格 | 対応不要 |
| ✗ **FAIL** | チェック失敗 | 🔴 すぐに対応 |
| ⚠️ **WARN** | 警告 | 🟡 近いうちに確認 |
| ℹ️ **INFO** | 情報 | 📖 参考情報 |

### 🛠️ 優先度別対応方法

#### 🔴 FAIL が出た場合（最優先！）

```
✗ FAIL: npm audit: Found 5 vulnerabilities
```

**対応方法：**
```bash
# 脆弱性を修正
npm audit fix
npm audit fix --force
```

#### 🟡 WARN が出た場合（次の対応）

```
⚠ WARN: SSH key permissions: 644 (should be 600)
```

**対応方法：**
```bash
# パーミッションを修正
chmod 600 ~/.ssh/id_rsa
```

#### 🟢 PASS が出た場合（対応不要）

```
✓ PASS: Git commit signing enabled
```

**何もしなくて大丈夫です！**

---

## よくある質問

### Q1: このツール、本当に安全ですか？

**A: はい。完全に安全です。**

理由：
- ✅ **オープンソース** - ソースコード全体が公開されている
- ✅ **何も削除しない** - ただ調査するだけ
- ✅ **インターネット送信なし** - あなたのパソコンだけで処理
- ✅ **MIT ライセンス** - 信頼できるライセンス

### Q2: やっぱり難しい？

**A: いいえ。5分で完了します。**

必要なステップ：
1. ツールをダウンロード（1分）
2. スクリプトを実行（1分）
3. 結果を確認（3分）

特別な知識は不要です。

### Q3: 何度も実行していいの？

**A: もちろん OK です。何度でも実行できます。**

おすすめ：
- 最初: フルチェック
- 毎週: セキュリティチェック
- 毎月: 詳細監査

```bash
# 毎週日曜午前2時に自動実行（Linux）
0 2 * * 0 /path/to/check-supply-chain-unix.sh
```

### Q4: エラーが出たら？

**A: よくあるエラーと対応方法：**

| エラー | 対応 |
|--------|------|
| `Permission denied` | `chmod +x *.sh` を実行 |
| `PowerShell policy error` | `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process` を実行 |
| `npm: command not found` | [Node.js をインストール](https://nodejs.org/) |

### Q5: 結果を人に見せたい場合？

**A: レポートファイルを共有できます。**

```bash
# メール送信
cat supply_chain_check_report_*.txt | mail -s "Security Report" admin@example.com

# または安全に暗号化
gpg --symmetric supply_chain_check_report_*.txt
```

---

## 🔐 セキュリティの秘訣

### 💡 このツールを最大限活用する3つのコツ

#### ✅ Tip 1: 定期的に実行する

セキュリティは「一度やったら終わり」ではありません。

```
初回: フルチェック
週1回: 定期チェック
月1回: 詳細監査
```

#### ✅ Tip 2: 結果を記録する

```bash
# 月ごとにバックアップ
cp supply_chain_check_report_*.txt ~/security_reports/
```

変化を追跡できます。

#### ✅ Tip 3: チーム全体で導入

個人だけでなく、**チーム全体**で導入すると効果的です：

```
チーム全員がツールを実行
  ↓
セキュリティ基準が統一される
  ↓
安全な開発環境が実現
```

### 🚀 次のステップ

1. **今日** - ツールをインストール・実行
2. **明日** - 結果を確認・対応
3. **来週** - 毎週実行を開始
4. **毎月** - チームで共有

---

## 📚 もっと詳しく知りたい人へ

このツールには、以下のドキュメントがあります：

| ドキュメント | 対象者 |
|-------------|--------|
| **BEGINNER_GUIDE.md** | 全く初めての人 |
| **QUICKSTART.md** | 5分で動かしたい人 |
| **README.md** | 詳しく知りたい人 |
| **IMPLEMENTATION_GUIDE.md** | カスタマイズしたい人 |

全て GitHub に無料で公開されています：
https://github.com/your-username/supplychain-check-tools

---

## まとめ

### 🎯 この記事のポイント

```
✅ サプライチェーン攻撃は誰にでも起こりうる
✅ でも対策方法がある - このツール！
✅ インストール～実行は5分
✅ 結果は自動的に詳しく報告される
✅ 無料・無害・安全
✅ 定期実行で継続的に保護
```

### 💪 あなたにできること

今すぐできる：
1. ツールをダウンロード
2. スクリプトを実行
3. 結果を確認
4. 問題があれば修正

それだけで、あなたの開発環境は **大幅に安全になります！**

### 🙏 最後に

セキュリティは「面倒な義務」ではなく、「必要な投資」です。

**5分の時間投資で、何千万円分の損失を防げます。**

ぜひ今日から始めてみてください！

---

## 🔗 リンク集

- 📥 **ダウンロード**: https://github.com/your-username/supplychain-check-tools
- 📖 **詳細ガイド**: https://github.com/your-username/supplychain-check-tools/blob/main/docs/BEGINNER_GUIDE.md
- 📚 **完全ドキュメント**: https://github.com/your-username/supplychain-check-tools/blob/main/README.md
- 📝 **実装ガイド**: https://github.com/your-username/supplychain-check-tools/blob/main/docs/IMPLEMENTATION_GUIDE.md

---

## 👨‍💻 このツールについて

- **作成者**: Supply Chain Security Tool Contributors
- **ライセンス**: MIT（自由に使える）
- **対応OS**: Windows、macOS、Linux、Raspberry Pi
- **バージョン**: 1.0.0
- **最終更新**: 2026年4月

---

**セキュアで安全な開発環境を！** 🔐✨

*「セキュリティは誰のためではなく、未来のあなたのため。」*

