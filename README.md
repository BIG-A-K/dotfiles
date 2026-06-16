# dot files
このリポジトリは私の開発環境のベースとなる設定ファイルを管理しています。

## 内容物
- `tmux.conf`
- `wezterm.lua`
- `gitconfig`
- `zshrc`
- `bashrc`: bashしかない小さい環境向けの最小設定ファイル
- `nvim/init.lua`: neovimの設定ファイル
- `vimrc`
- `alias`: エイリアスをまとめて設定したファイル。bashでも利用可能。追加ツールがある場合だけ拡張されます
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
完了したら以下を実行します。
- 最小構成
```sh
mise use -g bat starship tmux
```
- おすすめのライブラリ
```sh
mise use -g uv bat aws-cli bun claude-code delta starship opencode eza tmux dust
```

### 2. 設定の反映

リポジトリをsubmodule込みでcloneして、インストールスクリプトを実行します。

```sh
git clone --recurse-submodules https://github.com/BIG-A-K/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

すでにclone済みの場合は、以下でsubmoduleを取得します。

```sh
git submodule update --init --recursive
```

既存の設定ファイルがある場合は上書きせず、symlinkの作成をスキップします。`-f, --force` を指定すると、既存の実ファイルやディレクトリは `~/.dotfiles-backup/YYYYmmdd-HHMMSS/` に退避してからsymlinkを作成し、既存のsymlinkは上書きします。

Starshipの設定は `earth` がデフォルトです。別のプロファイルを使う場合は `--starship` を指定します。

利用可能なプロファイルは `mercury`, `venus`, `earth`, `mars`, `jupiter`, `saturn`, `uranus`, `neptune` です。

```sh
./install.sh --starship mars
```

変更内容だけ確認したい場合は `--dry-run` を使います。

```sh
./install.sh --dry-run
```

既存ファイルの退避やsymlinkの上書きも含めて反映する場合は `-f, --force` を使います。

```sh
./install.sh --force
```

作成される主なリンクは以下です。

- `~/.zshrc` -> `zshrc`
- `~/.bashrc` -> `bashrc`
- `~/.alias` -> `alias`
- `~/.gitconfig` -> `gitconfig`
- `~/.vimrc` -> `vimrc`
- `~/.tmux.conf` -> `tmux.conf`
- `~/.config/wezterm/wezterm.lua` -> `wezterm.lua`
- `~/.config/nvim` -> `nvim`
- `~/.config/starship.toml` -> `starship.conf/<profile>.toml`
- `~/.local/bin/imgcat` -> `scripts/imgcat`
