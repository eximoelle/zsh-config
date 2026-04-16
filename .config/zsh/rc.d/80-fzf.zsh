#!/bin/zsh

#
# FZF
#

command -v fzf > /dev/null ||
    return 0

# `**` занято под recursive glob, поэтому для fuzzy completion задаем
# отдельный trigger.
: ${FZF_COMPLETION_TRIGGER:=',,'}

# Общий вид fzf-окон стараемся держать единым, чтобы история, файлы и каталоги
# ощущались как части одного интерфейса.
: ${FZF_DEFAULT_OPTS:=--height=55% --layout=reverse --border=rounded \
--info=inline --preview-window=right,55%,border-left --bind=ctrl-/:toggle-preview}

# Для dotfiles и проектов полезно видеть hidden entries, но служебные каталоги
# лучше пропускать, чтобы FZF-виджеты не обходили их без необходимости.
: ${FZF_CTRL_T_OPTS:=--walker-skip=.git,node_modules,.venv}
: ${FZF_ALT_C_OPTS:=--walker-skip=.git,node_modules,.venv}

# Для `fzf --zsh` здесь используем обычный `eval`: так shell-интеграция
# поднимается сразу в текущей сессии и предсказуемо регистрирует бинды.
eval "$(fzf --zsh)"

# Виджет каталога из `fzf --zsh` кладет в `BUFFER` строку `builtin cd -- ...`.
# Здесь виджет сразу формирует чистую команду `cd -- ...`.
fzf-cd-widget() {
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(
    FZF_DEFAULT_COMMAND=${FZF_ALT_C_COMMAND:-} \
    FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=dir,follow,hidden --scheme=path" "${FZF_ALT_C_OPTS-} +m") \
    FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) < /dev/tty
  )"

  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi

  zle push-line
  BUFFER="cd -- ${(q)dir:a}"
  zle accept-line
  local ret=$?
  unset dir
  zle reset-prompt
  return $ret
}

# Переход в каталог привязан к Ctrl-X C, рядом с остальными shell helper-
# операциями. Назначаем это явно по keymap,
# чтобы после `fzf --zsh` не оставалось расхождений между emacs/viins/vicmd.
local keymap=''
for keymap in emacs viins vicmd; do
  bindkey -M $keymap -r '^[c'
  bindkey -M $keymap '^Xc' fzf-cd-widget
done
unset keymap

# Для выбора файлов показываем содержимое через bat, а для директорий — через
# eza. Это особенно удобно в dotfiles и больших репозиториях.
if command -v bat > /dev/null && command -v eza > /dev/null; then
  FZF_CTRL_T_OPTS+=" --preview 'if [[ -d {} ]]; then eza -1 --group-directories-first --color=always --icons=always {} 2>/dev/null; else bat --style=numbers --color=always --line-range=:200 {} 2>/dev/null; fi'"
  FZF_ALT_C_OPTS+=" --preview 'eza -la --group-directories-first --color=always --icons=always {} 2>/dev/null'"
fi

# История команд открывается в одном `fzf`-меню по стрелке вверх. Внутри него
# доступны загрузка в буфер, вставка и удаление записей.
autoload -Uz hist-fzf-widget
zle -N hist-fzf-widget

() {
  bindkey '^[[A' $1
  bindkey '^[OA' $1
  zle -N $1
  $1() {
    # В многострочном буфере стрелка вверх ходит по строкам текущего ввода.
    if [[ $BUFFER == *$'\n'* ]]; then
      zle .up-line-or-history
      return
    fi

    hist-fzf-widget "$BUFFER"
  }
} hist-fzf-up-widget

local keymap=''
for keymap in emacs viins vicmd; do
  bindkey -M $keymap -r '^R'
  bindkey -M $keymap '^[[A' hist-fzf-up-widget
  bindkey -M $keymap '^[OA' hist-fzf-up-widget
done
unset keymap
