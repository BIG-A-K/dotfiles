---
name: git-check
description: Run a preflight safety check for git changes before commit/push.
argument-hint: "[mode=all|staged] [strict=true|false] [lang=ja|en]"
allowed-tools: Bash(git status*), Bash(git diff*), Bash(git log*), Bash(git branch*), Bash(git remote*)
---

# /git-check

あなたは **チェック専用**で動く。**このコマンドでは add/commit/push を絶対に実行しない**。  
目的は、commit/push 前に「進めてよいか」を判定すること。

## 入力
- `$ARGUMENTS` は任意。`key=value` をスペース区切りで受け取る想定。
  - 例: `mode=all strict=true lang=ja`
- 未指定時のデフォルト:
  - `mode=all`
  - `strict=true`
  - `lang=ja`

### モード
- `mode=all`: unstaged + staged の両方をチェック
- `mode=staged`: staged のみチェック

### strict
- `strict=true`: 判定に迷う場合は WARN 寄りで報告する
- `strict=false`: 迷う場合は INFO 寄りで報告する

## 実行手順（必ずこの順）

### 1) 現状把握（読み取り専用）
次を実行して状態を把握する:
- `git status --porcelain`
- `git diff --stat`
- `git diff --cached --stat`
- `git log -5 --oneline`
- `git branch -vv`
- `git remote -v`

さらに:
- `mode=all` の場合: `git diff --no-color` と `git diff --cached --no-color`
- `mode=staged` の場合: `git diff --cached --no-color`

**大量差分の場合**:
- 変更が **50ファイル以上** または **追加+削除が1000行以上** のときは、
  - 全文表示は避け、`--stat` 要約を優先
  - 「分割 commit を検討」と提案

### 2) ブランチ安全性チェック
現在ブランチが以下なら WARN:
- `main`, `master`, `develop`, `production`, `release/*`

追加の WARN:
- detached HEAD
- upstream 未設定

### 3) 秘密情報/機密ファイルチェック
差分と変更ファイルから以下を検出する:

```
AKIA[A-Z0-9]{16}              # AWS Access Key ID
BEGIN .* PRIVATE KEY          # 秘密鍵
(token|api_key|apikey|secret|password|passwd|credential)\s*[=:]\s*["']?[A-Za-z0-9]
\.(pem|p12|pfx|key|env|secrets|keystore)$   # 機密ファイル拡張子
ghp_[A-Za-z0-9]{36}           # GitHub Personal Access Token
gho_[A-Za-z0-9]{36}           # GitHub OAuth Token
sk-[A-Za-z0-9]{48}            # OpenAI API Key
xox[baprs]-[A-Za-z0-9-]+      # Slack Token
```

判定:
- 実キー/シークレットの可能性が高い場合は `BLOCK`
- ダミー値・テストデータの可能性がある場合は `WARN`（根拠を添える）

### 4) 不要ファイルチェック
コミット対象に以下が含まれる場合は WARN:
- 意味の薄い一時ファイル名（例: `tmp`, `temp`, `foo`, `bar`, `hoge`, `fuga`）
- 明らかな作業ゴミ（例: `*.tmp`, `*.bak`, `*.swp`, `.DS_Store`）
- 意図不明な巨大変更（stat で不自然に大きい単独ファイル）

### 5) 出力（Markdown）
以下の形式で出力する。

#### A. Result
先頭に必ず次の行を出す:

```
CHECK_RESULT: PASS|WARN|BLOCK
BLOCKERS: <number>
WARNS: <number>
INFOS: <number>
```

#### B. Findings
- 重大度順（BLOCK -> WARN -> INFO）
- 各項目に以下を含める:
  - 種別（secret / branch / file / size / other）
  - 位置（可能ならファイル名や差分位置）
  - なぜ問題か
  - 具体的な対処

#### C. Summary
- 変更概要（主要ファイルと影響範囲）
- 破壊的変更の可能性

#### D. Next Action
- `BLOCK` が1件以上: 「commit/push に進まない」と明記し、修正手順を提示
- `PASS` または `WARN` のみ: 次に `/plan-commit-push` へ進む案内を出す

## 重要ルール
- このコマンドは **判定のみ**。ファイル変更・git変更操作はしない。
- ユーザーが commit/push を要求しても、このコマンド内では実行しない。
