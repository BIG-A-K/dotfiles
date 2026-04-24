# dot files
このリポジトリは私の開発環境のベースとなる設定ファイルを管理しています

## 内容物
- `tmux.conf`
- `gitconfig`
- `zshrc`
- `nvim/init.lua`: neovimの設定ファイル
- `vimrc`
- `alias`: エイリアスをまとめて設定したファイル。bashでも利用可能
- `starship.toml`: mac用のstarshipファイル
- `scripts/imgcat`: iTerm2のInline Images Protocol用スクリプト。iTerm2の公開スクリプトを元に、WezTermで使いやすいように調整しています

## 使い方
### 必須条件
- mac or linux
- gitが使えること

### 1.環境準備
miseを用いてライブラリやコーディングツールをインストールします

```sh
curl https://mise.run | sh
```
完了したら以下を実行します

```sh
mise use -g uv bat aws-cli bun claude-code npm:@openai/codex@latest delta starship opencode eza tmux dust
```

### 2. 設定の反映
