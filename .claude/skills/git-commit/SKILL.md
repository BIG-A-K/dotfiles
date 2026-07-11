---
name: git-commit
description: Generate commit message candidates from git changes, then (only with explicit approval) commit.
argument-hint: "[type=feat|fix|docs|refactor|test|chore] [scope=...] [lang=ja|en] [mode=auto|all|staged]"
allowed-tools: Bash(git status*), Bash(git diff*), Bash(git log*), Bash(git branch*), Bash(git remote*), Bash(git add*), Bash(git commit*)
---

# git-commit

## 入力
- `$ARGUMENTS` は任意。`key=value` をスペース区切りで受け取る想定。
  - 例: `type=fix scope=velocity_manager lang=ja mode=all`
- 未指定時のデフォルト:
  - `lang` は「言語の決定」に従う
  - `mode=auto`（以下の自動判定ルールに従う）
    - **staging 済みの変更がある場合**: staged のみを対象にする（unstaged は触らない）
    - **staging 済みの変更がない場合**: 全変更を add して commit（危険なら plan 内で注意して staged 推奨）
    - `mode=staged` を明示すれば常に staged のみ、`mode=all` を明示すれば常に全変更を対象にする
  - `type/scope` は差分から推定（推定に自信がない場合は複数案を出す）

## 言語の決定

`lang` 引数が明示的に指定された場合は、その言語を使う。
未指定の場合は次の手順で決定する。

1. リポジトリに `README.md`（または `README.*`）が存在する場合は、そのREADMEの本文で主に使われている言語を採用する。
2. READMEが存在しない場合は、デフォルトを **日本語（ja）** とする。

決定した言語は、Conventional Commits の `type`（`feat` / `fix` / `docs` など）を除く、description と本文の記述に適用する。

## TODO
- ステージングされた変更がない場合は、現在の変更を確認して適切な単位でステージングする
  - - 不要そうなファイルの検出: 例えば`tmp,temp`や`hoge,fuga`や`foo,bar`などの意味のないファイルが含まれている場合は警告を出す
- Conventional Commits 形式に従ったコミットメッセージを生成する:
```
1行目: <type>(<scope>): <description>
2行目: 空行
3行目以降: 変更内容を箇条書きで記述
```
- 重要: コミットメッセージは必ずユーザーが指定した言語（デフォルト: 日本語)で記述。 Conventional Commits 仕様はフォーマットの参考としてのみ使用し、実際のメッセージは指定された言語で記述すること
- git commit -m "<メッセージ>" でコミットを実行
- 1-4を必要に応じて繰り返し、すべての変更が適切な単位でコミットされるまで続ける
- コミット完了後、生成したコミットメッセージのみを出力してください。複数ある場合は、--- で区切って出力してください。


## 重要な安全ルール
- **禁止（許可があっても原則やらない）**: `--force` 系、`reset --hard`、自動 rebase,push
- 秘密情報っぽい差分があれば **STOP** して警告し、commit/push に進まない
