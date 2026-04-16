#!/bin/zsh

#
# Интеграция WezTerm
#

# Подключаем штатную shell integration только внутри WezTerm. Она дает:
# - prompt-зоны для навигации по выводу
# - актуальный cwd для новых вкладок/окон
# - pane user vars для последующей настройки status/tab title
if [[ $TERM_PROGRAM != WezTerm && -z ${WEZTERM_PANE-} ]]; then
  return 0
fi

local wezterm_shell='/Applications/WezTerm.app/Contents/Resources/wezterm.sh'
[[ -r $wezterm_shell ]] ||
    return 0

# Убираем лишний вызов `hostname` на каждый prompt: для локальной машины
# значения из zsh достаточно.
: ${WEZTERM_HOSTNAME:=$HOST}

source "$wezterm_shell"
