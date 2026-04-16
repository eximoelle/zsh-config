#!/bin/zsh

#
# Команды, функции и алиасы
#

# Алиасы задавайте в конце, чтобы они не влияли на определения функций.

# Позволяет переходить в директории без `cd`, просто вводя имя директории.
# Внимание: может быть конфликт, если есть алиас/функция/builtin/команда
# с тем же именем.
# В целом без `cd` обычно безопасно использовать:
#   ..  перейти на уровень выше
#   ~   перейти в домашнюю директорию
#   ~-2 перейти во вторую из недавно посещенных директорий
#   /   перейти в корень
setopt AUTO_CD

# Автозагрузка командных функций из `functions/auto` через `$fpath`.
typeset -a auto_functions
auto_functions=($ZDOTDIR/functions/auto/*(.N:t))
auto_functions=(${auto_functions:#*.zwc})
(( ${#auto_functions} )) && autoload -Uz $auto_functions
unset auto_functions

# Введите '-' для возврата в предыдущую директорию.
alias -- -='cd -'
# '--' означает конец опций. Иначе '-=...' мог бы интерпретироваться как флаг.

# Эти алиасы позволяют вставлять примеры команд без ошибок из-за символа prompt.
alias %= \$=

# zmv позволяет пакетно переименовывать (или копировать/линковать) файлы
# с помощью шаблонов.
# См. https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#index-zmv
autoload -Uz zmv
alias zmv='zmv -Mv'
alias zcp='zmv -Cv'
alias zln='zmv -Lv'

# В отличие от Bash, completion в Zsh не нужно отдельно настраивать для алиасов.
# Система распознает их автоматически.

# Привязка расширений файлов к программам для открытия.
# Так можно открыть файл, просто набрав его имя и нажав Enter.
# Точка в расширении подразумевается; `gz` ниже означает файлы .gz
alias -s {css,gradle,html,js,json,md,patch,properties,txt,xml,yml}=$PAGER
alias -s gz='gzip -l'
alias -s {log,out}='tail -F'

# Eza используем как основной листинг файлов, если бинарник установлен.
# Базовые алиасы сохраняют привычные имена команд, но дают более удобный
# вывод: директории идут первыми, иконки включаются автоматически, а для
# длинного листинга добавляется Git-статус.
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons=auto'
  alias l='eza --oneline --group-directories-first --icons=auto'
  alias ll='eza --long --header --git --group-directories-first --icons=auto'
  alias la='eza --long --header --all --git --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
  alias lta='eza --tree --level=2 --all --group-directories-first --icons=auto'
  alias tree='eza --tree --group-directories-first --icons=auto'
fi


# `< file` для быстрого просмотра содержимого текстового файла.
READNULLCMD=$PAGER  # Программа, которая будет использоваться для этого.
