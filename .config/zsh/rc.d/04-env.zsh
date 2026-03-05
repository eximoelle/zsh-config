#!/bin/zsh

#
# Переменные окружения
#

# -U гарантирует уникальность элементов (удаляет дубликаты).
export -U PATH path FPATH fpath MANPATH manpath
export -UT INFOPATH infopath  # -T создает "связанную" пару; см. ниже.

# $PATH и $path (а также $FPATH и $fpath и т.д.) связаны между собой.
# Изменение одного изменяет и другое.
# Каждый элемент массива разворачивается отдельно, поэтому можно использовать ~
# для $HOME в каждом элементе $path.
path=(
    /home/linuxbrew/.linuxbrew/bin(N)   # (N): пусто, если путь не существует
                                        # (в macOS пути не будет, в Linux при
                                        # установленном Linuxbrew — будет)
    ~/.local/bin
    $path
)

# Настраиваем Homebrew, если он уже установлен.
if command -v brew > /dev/null; then
    HOMEBREW_PREFIX=${HOMEBREW_PREFIX:-$(brew --prefix)}
    path=(
        $HOMEBREW_PREFIX/bin(N)
        $HOMEBREW_PREFIX/sbin(N)
        $path
    )
    # Обработчик "command not found"
    HOMEBREW_COMMAND_NOT_FOUND_HANDLER="$(brew --repository)/Library/Homebrew/command-not-found/handler.sh"
    if [ -f "$HOMEBREW_COMMAND_NOT_FOUND_HANDLER" ]; then
      source "$HOMEBREW_COMMAND_NOT_FOUND_HANDLER"
    fi
    # Полезные настройки Homebrew
    export HOMEBREW_NO_ENV_HINTS=1

fi

# Чтобы использовать `autoload` для функции в командной строке, ее нужно
# положить в $fpath или загружать по абсолютному пути.
# (Примечание: система completion в Zsh автоматически autoload'ит функции
# completion из директорий в $fpath, так что вручную это не нужно.)
fpath=(
    $ZDOTDIR/functions/auto
    $ZDOTDIR/functions
    ~/.local/share/zsh/site-functions
    $fpath
    # Директорию Homebrew добавляем в конец $fpath, чтобы использовать ее
    # completion только там, где zsh не знает completion сам.
    ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/zsh/site-functions}
)
# Внутри объявления массива тоже можно писать комментарии.

# Команда по умолчанию для просмотра текста в терминале.
# Не специфично для zsh, но используется многими утилитами.
export PAGER=less

# Текстовые редакторы по умолчанию для терминала.
if command -v zed >/dev/null 2>&1; then
  # Если Zed (https://zed.dev/) установлен — GUI редактором будет он
  export VISUAL=zed
elif command -v code >/dev/null 2>&1; then
  # Если Zed нет, но установлен VS Code — значит, он
  export VISUAL=code
else
  # Если нет ни того, ни другого — не экспортируем переменную VISUAL в принципе
  unset VISUAL
fi

# Консольный редактор используется Zsh (`fc`) и многими внешними командами.
if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
else
  # Подразумеваем, что nano будет всегда
  export EDITOR=nano
fi
