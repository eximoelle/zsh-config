#!/bin/zsh

#
# Менеджер плагинов
#

local znap_home=${XDG_DATA_HOME:-$HOME/.local/share}/zsh
local znap_repo=$znap_home/zsh-snap
local znap=$znap_repo/znap.zsh

# Автоустановка Znap, если он еще не установлен.
if ! [[ -r $znap ]]; then   # Проверяем, что файл существует и читается.
  if command -v git > /dev/null; then
    mkdir -p $znap_home
    git -C $znap_home clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git 2> /dev/null ||
        print -u2 -- "zsh: warning: failed to clone znap into $znap_home"
  else
    print -u2 -- "zsh: warning: git is not installed; skipping znap setup"
  fi
fi

[[ -r $znap ]] &&
    . $znap   # Загружаем Znap.
