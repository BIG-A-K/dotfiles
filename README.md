# dot files
このリポジトリは私の開発環境のベースとなる設定ファイルを管理しています。

## 内容物
- `tmux.conf`
- `gitconfig`
- `zshrc`
- `nvim/init.lua`: neovimの設定ファイル
- `vimrc`
- `alias`: エイリアスをまとめて設定したファイル。bashでも利用可能
- `starship.conf/*.toml`: starshipの設定ファイル
- `scripts/imgcat`: iTerm2のInline Images Protocol用スクリプト。iTerm2の公開スクリプトを元に、WezTermで使いやすいように調整しています
- `install.sh`: 各設定ファイルをホームディレクトリへsymlinkするスクリプト

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

リポジトリをcloneして、インストールスクリプトを実行します。

```sh
git clone https://github.com/BIG-A-K/dot_files.git ~/dot_files
cd ~/dot_files
./install.sh
```

既存の設定ファイルがある場合は `~/.dotfiles-backup/YYYYmmdd-HHMMSS/` に退避してからsymlinkを作成します。

Starshipの設定は `earth` がデフォルトです。別のプロファイルを使う場合は `--starship` を指定します。

```sh
./install.sh --starship mars
```

変更内容だけ確認したい場合は `--dry-run` を使います。

```sh
./install.sh --dry-run
```

作成される主なリンクは以下です。

- `~/.zshrc` -> `zshrc`
- `~/.alias` -> `alias`
- `~/.gitconfig` -> `gitconfig`
- `~/.vimrc` -> `vimrc`
- `~/.tmux.conf` -> `tmux.conf`
- `~/.config/nvim` -> `nvim`
- `~/.config/starship.toml` -> `starship.conf/<profile>.toml`
- `~/.local/bin/imgcat` -> `scripts/imgcat`
