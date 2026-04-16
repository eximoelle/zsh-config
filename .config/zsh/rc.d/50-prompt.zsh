#!/bin/zsh

#
# Темы prompt через штатную систему `prompt`.
#

typeset -g PROMPT_THEME_DIR=${ZDOTDIR:-$HOME/.config/zsh}/themes
typeset -g PROMPT_STARSHIP_THEME_DIR=$PROMPT_THEME_DIR/starship
typeset -g PROMPT_STARSHIP_DEFAULT_PRESET=git-right

# Pure не нужно source'ить: достаточно добавить его каталог в fpath, тогда
# promptinit увидит `prompt_pure_setup` как обычную тему Zsh.
if (( ${+functions[znap]} )); then
  if znap clone sindresorhus/pure >/dev/null 2>&1; then
    fpath=( ~[sindresorhus/pure] $fpath )
  fi
fi

prompt_starship_presets() {
  emulate -L zsh
  local -a presets=( "$PROMPT_STARSHIP_THEME_DIR"/*.toml(N:t:r) )
  print -rl -- $presets
}

prompt_starship_help() {
  emulate -L zsh

  print 'Starship prompt presets:'
  print "  prompt starship  # default preset (${PROMPT_STARSHIP_DEFAULT_PRESET})"
  print "  prompt starship ${PROMPT_STARSHIP_DEFAULT_PRESET}"

  local preset=''
  for preset in ${(f)"$(prompt_starship_presets)"}; do
    [[ $preset == $PROMPT_STARSHIP_DEFAULT_PRESET ]] && continue
    print "  prompt starship $preset"
  done
}

prompt_starship_cleanup() {
  emulate -L zsh

  if [[ -n ${__starship_preserved_zle_keymap_select-} ]]; then
    zle -N zle-keymap-select "$__starship_preserved_zle_keymap_select" 2>/dev/null
  else
    zle -D zle-keymap-select 2>/dev/null
  fi

  unfunction starship_zle-keymap-select 2>/dev/null
  unfunction starship_zle-keymap-select-wrapped 2>/dev/null

  if (( ${__prompt_starship_had_starship_config:-0} )); then
    export STARSHIP_CONFIG=$__prompt_starship_saved_starship_config
  else
    unset STARSHIP_CONFIG
  fi

  if (( ${__prompt_starship_had_virtual_env_disable_prompt:-0} )); then
    export VIRTUAL_ENV_DISABLE_PROMPT=$__prompt_starship_saved_virtual_env_disable_prompt
  else
    unset VIRTUAL_ENV_DISABLE_PROMPT
  fi

  unset __prompt_starship_had_starship_config
  unset __prompt_starship_had_virtual_env_disable_prompt
  unset __prompt_starship_saved_starship_config
  unset __prompt_starship_saved_virtual_env_disable_prompt
  unset __starship_preserved_zle_keymap_select

  unset STARSHIP_CAPTURED_TIME
  unset STARSHIP_CMD_STATUS
  unset STARSHIP_DURATION
  unset STARSHIP_JOBS_COUNT
  unset STARSHIP_PIPE_STATUS
  unset STARSHIP_SESSION_KEY
  unset STARSHIP_SHELL
  unset STARSHIP_START_TIME
}

prompt_starship_setup() {
  emulate -L zsh
  prompt_opts=(cr percent sp subst)

  (( ${+commands[starship]} )) || {
    print -u2 -- 'prompt starship: command not found: starship'
    return 1
  }

  local preset=${1:-$PROMPT_STARSHIP_DEFAULT_PRESET}
  local config="$PROMPT_STARSHIP_THEME_DIR/$preset.toml"

  [[ -r $config ]] || {
    print -u2 -- "prompt starship: unknown preset: $preset"
    prompt_starship_help >&2
    return 1
  }

  if [[ -v STARSHIP_CONFIG ]]; then
    typeset -g __prompt_starship_had_starship_config=1
    typeset -g __prompt_starship_saved_starship_config=$STARSHIP_CONFIG
  else
    typeset -g __prompt_starship_had_starship_config=0
    unset __prompt_starship_saved_starship_config
  fi

  if [[ -v VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    typeset -g __prompt_starship_had_virtual_env_disable_prompt=1
    typeset -g __prompt_starship_saved_virtual_env_disable_prompt=$VIRTUAL_ENV_DISABLE_PROMPT
  else
    typeset -g __prompt_starship_had_virtual_env_disable_prompt=0
    unset __prompt_starship_saved_virtual_env_disable_prompt
  fi

  export STARSHIP_CONFIG=$config

  if (( ${+functions[znap]} )); then
    znap eval starship 'starship init zsh'
  else
    source <(starship init zsh)
  fi

  prompt_cleanup prompt_starship_cleanup
}

# promptinit сам найдет built-in темы и Pure через fpath. Для Starship добавляем
# небольшую обертку вручную, чтобы он переключался через `prompt starship`.
promptinit() {
  unfunction promptinit
  autoload -Uz promptinit && promptinit

  (( $+functions[prompt_starship_setup] )) &&
      prompt_themes+=( starship )

  prompt_themes=( "${(@on)prompt_themes}" )
}

prompt-theme() {
  emulate -L zsh
  setopt extendedglob

  local action=${1:-list}
  case $action in
    list)
      print 'Prompt themes:'

      local theme=''
      for theme in $prompt_themes; do
        if [[ $theme == starship ]]; then
          print "  prompt starship"
          print "  prompt starship ${PROMPT_STARSHIP_DEFAULT_PRESET}"

          local preset=''
          for preset in ${(f)"$(prompt_starship_presets)"}; do
            [[ $preset == $PROMPT_STARSHIP_DEFAULT_PRESET ]] && continue
            print "  prompt starship $preset"
          done
          continue
        fi

        print "  prompt $theme"
      done
      ;;
    preview)
      local target=${2-}
      [[ -n $target ]] || {
        print -u2 -- 'Usage: prompt-theme preview <theme|starship:preset>'
        return 1
      }

      if [[ $target == starship:* ]]; then
        prompt starship "${target#starship:}"
      else
        prompt "$target"
      fi
      ;;
    *)
      print -u2 -- 'Usage: prompt-theme [list|preview <theme|starship:preset>]'
      return 1
      ;;
  esac
}

prompt_activate_startup_theme() {
  # Функция выбирает стартовую тему и сохраняет активными shell-опции prompt,
  # которые настраивает выбранная тема, например `promptsubst` для Starship.

  if (( ${+commands[starship]} )); then
    prompt starship "$PROMPT_STARSHIP_DEFAULT_PRESET" && return 0
  fi

  if [[ -n ${prompt_themes[(r)pure]-} ]]; then
    prompt pure && return 0
  fi

  prompt default
}

promptinit
prompt_activate_startup_theme
