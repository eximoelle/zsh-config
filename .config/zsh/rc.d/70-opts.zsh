#!/bin/zsh

#
# Опции shell, которым не нашлось места в других файлах.
#

# Задаем их после загрузки плагинов, так как плагины тоже могут менять опции.

# Не позволять `>` молча перезаписывать файлы. Для перезаписи используйте `>!`.
setopt NO_CLOBBER

# Считать вставленные в командную строку комментарии комментариями, а не кодом.
setopt INTERACTIVE_COMMENTS

# Не считать неисполняемые файлы из $path командами.
# Это убирает их из подсказок completion. На старых системах может повлиять
# на производительность, но на современных обычно проблем нет.
setopt HASH_EXECUTABLES_ONLY

# Включаем ** и *** как сокращения для **/* и ***/* соответственно.
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#Recursive-Globbing
setopt GLOB_STAR_SHORT

# Сортировать числа по числовому порядку, а не лексикографически.
setopt NUMERIC_GLOB_SORT

# `zcolors` дает хорошую базовую палитру для completion и подсветки,
# но muted-элементы красит в `bright black` (`90` / `fg=8`), который
# на части тем проваливается почти в фон. Оставляем саму палитру zcolors
# и меняем только этот проблемный цвет на приглушенный default color.
() {
  emulate -L zsh

  typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=default,faint'

  local key=''
  for key in comment path_prefix_pathseparator; do
    [[ -n ${ZSH_HIGHLIGHT_STYLES[$key]-} ]] || continue
    ZSH_HIGHLIGHT_STYLES[$key]=${ZSH_HIGHLIGHT_STYLES[$key]//fg=8/fg=default,faint}
  done

  local -a completion_colors=()
  zstyle -a ':completion:*:default' list-colors completion_colors ||
      return 0

  integer i=0
  for i in {1..$#completion_colors}; do
    completion_colors[i]=${completion_colors[i]//90/02}
  done

  zstyle ':completion:*:default' list-colors $completion_colors
}
