# Supply Chain Security Helper Tools

同梱ファイル:

- `supplychain-check.sh`
  - プロジェクトの設定状態をチェック
  - Node.js / Python / Go / Rust をざっくり自動判定
  - `.npmrc`, `package-lock.json`, `requirements.txt`, `pyproject.toml`, `go.sum`, `Cargo.lock`, `.github/workflows` などを確認

- `supplychain-install-helper.sh`
  - ベースライン設定を入れる補助ツール
  - デフォルトは **dry-run**（変更しない）
  - `--apply` を付けたときだけ書き込み
  - 既存ファイルは `.supplychain-tool-backup-YYYYmmdd-HHMMSS/` にバックアップ

## 使い方

```bash
chmod +x supplychain-check.sh supplychain-install-helper.sh
./supplychain-check.sh .
./supplychain-install-helper.sh --type auto
./supplychain-install-helper.sh --apply --type node --takumi yes
./supplychain-check.sh .
```

## 想定フロー

1. まず `supplychain-check.sh` で現状確認
2. 次に `supplychain-install-helper.sh` を dry-run で確認
3. 問題なければ `--apply`
4. 最後に `supplychain-check.sh` を再実行

## 注意

- これは「初心者が何を直せばいいか」を見える化するための **補助ツール** です
- 本番導入前に、既存の CI / private registry / 社内ルールと競合しないか確認してください
- `pyproject.toml` は自動マージ事故を避けるため、基本はスニペット提示にしています
