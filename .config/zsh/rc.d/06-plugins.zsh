#!/bin/zsh

#
# Плагины
#

(( ${+functions[znap]} )) ||
    return 0

# Плагины из GitHub (формат: owner/repo).
# -a задает тип переменной "массив".
local -a plugins=(
    marlonrichert/zsh-autocomplete      # Синхронное автодополнение
    marlonrichert/zsh-edit              # Улучшенные хоткеи редактирования
    marlonrichert/zsh-hist              # Работа с историей из командной строки
    marlonrichert/zcolors               # Цвета для completion и Git
    zsh-users/zsh-autosuggestions       # Inline-подсказки
    zsh-users/zsh-syntax-highlighting   # Подсветка синтаксиса
)

# Локальные плагины для разработки без публикации на GitHub.
# Можно указывать:
# - путь к директории плагина (например ~/dev/zsh-completions)
# - путь к .plugin.zsh/.zsh файлу
local -a local_plugins=(
    # ~/dev/zsh-completions
)

# Плагин Zsh Autocomplete отправляет в терминал очень много символов.
# Обычно это нормально на локальной машине, но при медленном SSH можно
# добавить задержку перед показом автодополнения:
#   zstyle ':autocomplete:*' min-delay 0.5  # seconds
#
# Если соединение совсем медленное, можно отключить автодополнение
# и оставить только completion по Tab:
#   zstyle ':autocomplete:*' async no


# Ускоряем первый запуск: клонируем все плагины параллельно.
# Уже клонированные репозитории пропускаются.
if (( ${#plugins} > 0 )); then
  znap clone $plugins
fi

# Загружаем GitHub-плагины по одному.
local p=
for p in $plugins; do
  znap source $p
done

# Загружаем локальные плагины без клонирования.
local lp='' lp_path='' lp_file='' lp_name=''
for lp in $local_plugins; do
  lp_path=${~lp}

  if [[ -f "$lp_path" ]]; then
    source "$lp_path"
    continue
  fi

  if [[ -d "$lp_path" ]]; then
    lp_name=${lp_path:t}
    lp_file=''

    for lp_file in \
      "$lp_path/$lp_name.plugin.zsh" \
      "$lp_path/$lp_name.zsh" \
      "$lp_path/init.zsh" \
      "$lp_path"/*.plugin.zsh(N[1]) \
      "$lp_path"/*.zsh(N[1]); do
      [[ -f "$lp_file" ]] || continue
      source "$lp_file"
      break
    done

    if [[ ! -f "$lp_file" ]]; then
      print -u2 -- "zsh: local plugin entry has no loadable .zsh file: $lp"
    fi

    continue
  fi

  print -u2 -- "zsh: local plugin entry not found: $lp"
done

# `znap eval <name> '<command>'` похож на `eval "$( <command> )"`,
# но с кэшированием и компиляцией вывода, что примерно в 10 раз быстрее.
# Пример для Starship (https://starship.rs/):
#   znap eval starship 'starship init zsh'
# вместо:
#   eval "$(starship init zsh)" (как требует инструкция по установке)
znap eval zcolors zcolors   # Для zcolors нужна дополнительная инициализация.
