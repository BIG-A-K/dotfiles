---
name: git-skill
description: プロジェクトのgit規約（コミット形式・ブランチ命名・ワークフロー）を定義・検出・適用するSkill。「git規約を確認」「ブランチ命名規則」「コミット規約」等で使う。
argument-hint: "[action=detect|show|apply] [lang=ja|en]"
allowed-tools: Bash(git:*), Bash(ls:*), Bash(cat:*), Bash(grep:*), Bash(head:*), Bash(tail:*), Read, AskUserQuestion
---

# git-skill

プロジェクトのgit運用規約を検出・定義・適用するSkill。
GitHub依存なし。ローカルリポジトリのみで動作する。

## Arguments

- `action`: 実行するアクション
  - `detect`（デフォルト）: リポジトリから規約を自動検出して提示
  - `show`: 検出済みの規約を表示
  - `apply`: 規約をCLAUDE.mdやREADMEに反映（ユーザー承認後）
- `lang`: 出力言語。デフォルトはREADMEの言語、なければ `ja`

## Task

### Phase 1: リポジトリ分析

以下を並列で取得する:

- `git log --oneline -50`: 直近のコミットメッセージ
- `git branch -a`: ブランチ一覧
- `git log --all --oneline --graph -20`: ブランチ構造の概要
- `git remote -v`: リモート構成
- CLAUDE.md / AGENTS.md / CONTRIBUTING.md / README.md の有無と内容

### Phase 2: 規約の検出

コミットログとブランチ名のパターンを分析し、以下を検出する。

#### コミット規約

- **形式**: Conventional Commits / Angular / 自由形式 / その他
- **prefix**: `feat`, `fix`, `docs` 等の使用頻度と一覧
- **scope**: `(scope)` の使用有無とスコープ一覧
- **言語**: コミットメッセージの主要言語
- **本文**: 本文の有無、箇条書きの使用率
- **Co-Authored-By**: 使用有無

一貫性スコア（0-100%）を算出する。80%以上なら「確立された規約あり」、50-80%なら「部分的に統一」、50%未満なら「規約未確立」と判定する。

#### ブランチ命名規則

- **パターン**: `feature/`, `fix/`, `hotfix/`, `release/` 等のprefix使用
- **区切り文字**: `/`, `-`, `_`
- **issue番号**: ブランチ名にissue番号を含むか
- **命名例**: 検出されたパターンの代表例

#### ワークフロー

- **mainブランチ**: `main` or `master`
- **開発ブランチ**: `develop` の有無
- **マージ戦略**: merge commit / squash / rebase の傾向（`git log --merges` と `git log --no-merges` の比率）
- **タグ**: バージョンタグの形式（`v1.0.0`, `1.0.0` 等）

### Phase 3: 規約の提示

検出結果を以下の形式で提示する:

```markdown
## Git規約レポート

### コミット規約
- 形式: Conventional Commits
- 一貫性: 92%
- prefix: feat(45%), fix(30%), docs(10%), refactor(8%), chore(7%)
- scope: 使用あり（auth, api, ui）
- 言語: 日本語
- 例: `feat(auth): ログイン画面にOAuth連携を追加`

### ブランチ命名
- パターン: `<type>/<description>`
- type: feature, fix, hotfix
- 例: `feature/add-oauth-login`

### ワークフロー
- mainブランチ: main
- マージ戦略: squash merge
- タグ形式: v1.0.0
```

### Phase 4: 規約の適用（`action=apply` の場合のみ）

検出・提示した規約をドキュメントに反映する。

1. CLAUDE.md の `## コミット規約` セクションを更新（または新規作成）
2. 変更内容をユーザーに提示し、AskUserQuestion で承認を取る
3. 承認後にファイルを更新

**重要**: `action=apply` でもファイル変更はユーザー承認後にのみ行う。

## 重要ルール

- このSkillはgit操作（commit, push, branch作成等）を行わない。分析と提示のみ。
- 既存の規約ドキュメント（CLAUDE.md等）に記載がある場合は、検出結果と照合して矛盾があれば指摘する。
- 規約が確立されていない場合は、検出されたパターンを基にした推奨案を提示する。
