#!/bin/zsh

#
# Привязки клавиш
#

# zsh-autocomplete и zsh-edit добавляют много полезных биндов. Полный список:
# https://github.com/marlonrichert/zsh-autocomplete/blob/main/README.md#key-bindings
# https://github.com/marlonrichert/zsh-edit/blob/main/README.md#key-bindings

# Разрешаем использовать Ctrl-Q и Ctrl-S для сочетаний клавиш.
unsetopt FLOW_CONTROL

# Alt-Q
# - На основном prompt: временно отложить текущую команду и набрать новую.
#   Старая строка вернется по Alt-G или автоматически на следующей строке.
# - На continuation prompt: перенести все введенные строки на основной prompt,
#   чтобы редактировать их вместе.
bindkey '^[q' push-line-or-edit

# Alt-H: помощь по текущей команде.
unalias run-help 2> /dev/null   # Удаляем простую версию по умолчанию.
autoload -RUz run-help          # Загружаем расширенную версию.
# -R сразу резолвит функцию, чтобы получить путь к исходнику.

# Загружаем $functions_source — ассоциативный массив, который сопоставляет
# каждую функцию с файлом, где она определена.
zmodload -F zsh/parameter p:functions_source

# Лениво загружаем все helper-функции run-help-* из той же директории.
autoload -Uz $functions_source[run-help]-*~*.zwc  # Исключаем .zwc файлы.

# Alt-V: показать код следующей комбинации клавиш и ее действие. Может быть
# полезно, если понадобятся собственные бинды.
bindkey '^[v' describe-key-briefly

# Alt-W: введите имя zsh-виджета и Enter, чтобы увидеть привязанные клавиши.
# Можно ввести часть имени и получить автодополнение.
bindkey '^[w' where-is

# Alt-Shift-S: добавить `sudo` к текущей или предыдущей команде.
() {
  bindkey '^[S' $1  # Привязываем Alt-Shift-S к виджету ниже.
  zle -N $1         # Создаем виджет, который вызывает функцию ниже.
  $1() {            # Создаем функцию.
    # Если строка пустая или содержит только пробелы, сначала подгружаем
    # предыдущую команду.
    [[ $BUFFER == [[:space:]]# ]] &&
        zle .up-history

    # $LBUFFER — часть строки слева от курсора.
    # Так мы сохраняем позицию курсора.
    LBUFFER="sudo $LBUFFER"
  }
} .sudo
