#!/bin/zsh

#
# Тема prompt
#

# Ускоряем старт: левая часть основного prompt появляется сразу.
if (( ${+functions[znap]} )); then
  znap prompt launchpad
else
  # Резервная инициализация prompt, если znap недоступен.
  autoload -Uz prompt_launchpad_setup
  prompt_launchpad_setup
fi

# `znap prompt` может autoload'ить нашу функцию prompt, потому что в 04-env.zsh
# мы добавили ее родительскую директорию в $fpath.
