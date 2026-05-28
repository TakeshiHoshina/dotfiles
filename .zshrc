

# ------------------------------------------------------------------------------
# 1. 補完機能（Tabキーの強化）
# ------------------------------------------------------------------------------
# 補完機能を有効化するモジュールをロード
autoload -U compinit

# 1日1回だけ補完キャッシュを更新し、2回目以降はキャッシュを再利用して起動を高速化する
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# 大文字・小文字を区別せずに補完する（例: 'cd desktop' で 'Desktop' に移動できる）
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Tabキーの補完候補一覧で、ファイルの種別（フォルダ、実行ファイル等）にマークを表示
setopt list_types

# 補完候補が大量にあっても、画面をスクロールさせずその場で候補を綺麗に表示する
setopt always_last_prompt

# カーソルの前後を挟んでTabキーで間を補完できる 「in|.ts」->「index.ts」
setopt complete_in_word


# ------------------------------------------------------------------------------
# 2. 履歴検索
# ------------------------------------------------------------------------------
HISTFILE=~/.zsh_history    # 履歴を保存するファイル名
HISTSIZE=1000000           # メモリ上に保存する履歴の最大数
SAVEHIST=1000000           # ファイルに保存する履歴の最大数

# 重複するコマンド履歴を無視
setopt hist_ignore_all_dups

# 先頭にスペース（空白）を入れて打ったコマンドは、履歴に残さない（パスワード入力等）
setopt hist_ignore_space

# 複数のターミナルウィンドウやタブ間でコマンド履歴を共有
setopt share_history

# コマンド前後の無駄な空白（スペース連打など）を詰めて綺麗に履歴に記録する
setopt hist_reduce_blanks

# [Ctrl + P] で「入力中の文字から始まる過去の履歴」を上に遡る
bindkey '^P' history-beginning-search-backward
# [Ctrl + N] で「入力中の文字から始まる過去の履歴」を下に下る
bindkey '^N' history-beginning-search-forward


# ------------------------------------------------------------------------------
# 3. ディレクトリ移動の自動化（cdの強化）
# ------------------------------------------------------------------------------
# フォルダ名を入力してEnterを押すだけで、'cd' を打たなくても移動できる
setopt auto_cd

# 普通に 'cd' で移動したときも、移動履歴（スタック）に自動で保存する
setopt auto_pushd

# 履歴（スタック）に移動する際、移動のたびに全履歴を画面に表示して汚すのを防ぐ
setopt pushd_silent

# 移動履歴（スタック）内の重複したフォルダは、古い方を自動で削除する
setopt pushd_ignore_dups

# ディレクトリ履歴を遡る数字の指定で、直感的に「1つ前」をマイナスで指定しやすくする
setopt pushd_minus


# ------------------------------------------------------------------------------
# 4. ターミナルの色付け（視認性アップ）
# ------------------------------------------------------------------------------
# 画面表示に色をつけるためのモジュールをロード
autoload -Uz colors
colors

# 日本語のファイル名やフォルダ名を文字化けさせずに正しく表示する
setopt print_eight_bit

# ファイルの種類ごとに色分けるためのカラーコード定義
export LS_COLORS='di=36;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;46'

# Tabキーの補完候補一覧にも、上記と同じ色付けを適用する
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Mac環境（darwin）の場合、'ls' コマンドを叩いたときに自動で色付き表示（-GF）にする
case "${OSTYPE}" in
darwin*)
  alias ls="ls -GF"
  ;;
esac


# ------------------------------------------------------------------------------
# 5. Git状態の自動表示とプロンプト設定
# ------------------------------------------------------------------------------
# プロンプトのカスタム変数（Git情報など）を毎回Enterを押すたびに最新に更新する
setopt prompt_subst

# Gitの情報を取得するモジュールをロード
autoload -Uz vcs_info
autoload -Uz is-at-least

# Git用プロンプトの表示フォーマットを設定（緑色でブランチ名を表示）
zstyle ':vcs_info:*' formats '%F{green}(%s)-[%b]%f'
zstyle ':vcs_info:*' actionformats '%F{green}(%s)-[%b|%a]%f'

if is-at-least 4.3.10; then
  zstyle ':vcs_info:git:*' check-for-changes true
  zstyle ':vcs_info:git:*' stagedstr   '*'  # コミット待ちの変更がある時のマーク
  zstyle ':vcs_info:git:*' unstagedstr '*'  # ステージされていない変更がある時のマーク
  zstyle ':vcs_info:git:*' formats       '%F{green}(%s)-[%b]%f %F{magenta}%c%u%f'
  zstyle ':vcs_info:git:*' actionformats '%F{green}(%s)-[%b|%a]%f %F{magenta}%c%u%f'
fi

# コマンドを実行する直前に、常に最新のGit状態を読み込む
precmd () {
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    psvar[1]="$vcs_info_msg_0_"
}

# プロンプトの見た目定義
PROMPT=$'%{${fg[blue]}%}%~%{${reset_color}%} %1(v|$psvar[1]|) %(!.#.$) '


# ------------------------------------------------------------------------------
# 6. エイリアス（ショートカット）
# ------------------------------------------------------------------------------

# エイリアスを実行した際、展開後の実際のコマンドをターミナルに表示する
unsetopt complete_aliases
alias_preexec() {
    # 実行しようとしている最初の単語（コマンド名）を取得
    local cmd=${1%% *}
    
    # それがエイリアスとして登録されているかチェック
    if [[ -n "${aliases[$cmd]}" ]]; then
        local expansion="${aliases[$cmd]}"
        
        # エイリアスの展開前後でが同一の場合（lsなどの標準エイリアス）は無視
        if [[ "$expansion" == "$cmd "* || "$expansion" == "$cmd" ]]; then
            return
        fi
        
        # それ以外はカスタムエイリアス（ghpoなど）と判定して表示
        echo "${fg[green]}▶ Executing: ${expansion} ${1#* }${reset_color}"
    fi
}
# zshの実行前フック（preexec）に上記の関数を登録
autoload -Uz add-zsh-hook
add-zsh-hook preexec alias_preexec

# ghエイリアス
alias ghpo="git push origin \$(git branch --show-current) --force-with-lease"
alias ghprc="gh pr create --base main \$(git branch --show-current)"
alias gcmm="git commit -m"
alias gcma="git commit --amend"