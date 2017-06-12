#キーバインド
bindkey -e
setopt auto_cd
## カレントディレクトリ中に指定されたディレクトリが見つからなかった場合に
## 移動先を検索するリスト。
cdpath=(~)

# 履歴
HISTFILE=~/.zsh_history
HISTSIZE=10000000
SAVEHIST=$HISTSIZE
setopt hist_ignore_dups
setopt hist_ignore_space
setopt inc_append_history
setopt share_history
setopt no_flow_control

# プロンプト
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats \
    '(%{%F{white}%K{green}%}%s%{%f%k%})-[%{%F{white}%K{blue}%}%b%{%f%k%}]'
zstyle ':vcs_info:*' actionformats \
    '(%{%F{white}%K{green}%}%s%{%f%k%})-[%{%F{white}%K{blue}%}%b%{%f%k%}|%{%F{white}%K{red}%}%a%{%f%k%}]'
prompt_bar_left_self="(%{%B%}%n%{%b%}%{%F{cyan}%}@%{%f%}%{%B%}%m%{%b%})"
prompt_bar_left_status="(%{%B%F{white}%(?.%K{green}.%K{red})%}%?%{%k%f%b%})"
prompt_bar_left_date="<%{%B%}%D{%Y/%m/%d %H:%M}%{%b%}>"
prompt_bar_left="-${prompt_bar_left_self}-${prompt_bar_left_status}-${prompt_bar_left_date}-"
prompt_bar_right="-[%{%B%K{magenta}%F{white}%}%d%{%f%k%b%}]-"
prompt_left="-[%h]%(1j,(%j),)%{%B%}%#%{%b%} "
count_prompt_characters()
{
    print -n -P -- "$1" | sed -e $'s/\e\[[0-9;]*m//g' | wc -m | sed -e 's/ //g'
}
update_prompt()
{
    local bar_left_length=$(count_prompt_characters "$prompt_bar_left")
    local bar_rest_length=$[COLUMNS - bar_left_length]
    local bar_left="$prompt_bar_left"
    local bar_right_without_path="${prompt_bar_right:s/%d//}"
    local bar_right_without_path_length=$(count_prompt_characters "$bar_right_without_path")
    local max_path_length=$[bar_rest_length - bar_right_without_path_length]
    bar_right=${prompt_bar_right:s/%d/%(C,%${max_path_length}<...<%d%<<,)/}
    local separator="${(l:${bar_rest_length}::-:)}"
    bar_right="%${bar_rest_length}<<${separator}${bar_right}%<<"
    PROMPT="${bar_left}${bar_right}"$'\n'"${prompt_left}"
    RPROMPT="[%{%B%F{white}%K{magenta}%}%~%{%k%f%b%}]"
    LANG=C vcs_info >&/dev/null
    if [ -n "$vcs_info_msg_0_" ]; then
        RPROMPT="${vcs_info_msg_0_}-${RPROMPT}"
    fi
}
precmd_functions=($precmd_functions update_prompt)

# 補完
autoload -U compinit
compinit
zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*:default' list-colors ""
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z} r:|[._-]=*'
zstyle ':completion:*' completer \
    _oldlist _complete _match _history _ignored _approximate _prefix
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' verbose yes
zstyle ':completion:sudo:*' environ PATH="$SUDO_PATH:$PATH"
setopt complete_in_word
setopt glob_complete
setopt hist_expand
setopt no_beep
setopt numeric_glob_sort

#エイリアス
alias e="emacs &"
alias g++="g++ -std=c++0x"
alias ls="ls -G"
alias la="ls -alhG"

#環境依存
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

alias imgls="${HOME}/.iterm/imgls"
alias imgcat="${HOME}/.iterm/imgcat"

eval "$(pyenv init -)"
eval "$(rbenv init -)"


alias sshmux="~/dotfiles/shellscript/sshmux.sh"
case "$TERM" in
    dumb | emacs)
        PROMPT="%m:%~> "
        unsetopt zle
        ;;
esac
export PATH="/usr/local/sbin:$PATH"
