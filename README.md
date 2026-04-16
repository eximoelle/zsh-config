Модульный конфиг Zsh для macOS + Homebrew и Ubuntu + Linuxbrew.

## Ключевые особенности

- модульная структура с предсказуемым порядком загрузки (`rc.d`)
- единая модель кастомизации: правки делаются прямо в модулях `rc.d/*`
- установка и бэкап существующей конфигурации через Make
- приглашение шелла на штатной системе `promptinit` с переключаемыми темами `default`, `pure` и `starship`
- стартовая тема `starship git-right` с фоллбэком: `pure`, затем built-in `default`, если `starship` или `Pure` недоступны
- симпатичные минималистичные Starship-пресеты в `.config/zsh/themes/starship` и helper-команда `prompt-theme`
- готовый набор плагинов + автоинициализация Znap
- `fzf`-интеграция для истории, файлов и перехода по каталогам, с превью через `bat`/`eza`, если они установлены
- привычные `ls`-алиасы поверх `eza` для короткого, длинного и tree-режимов
- штатная shell integration для WezTerm: prompt-зоны и корректный `cwd` для новых вкладок/окон
- автозагружаемые функции из `.config/zsh/functions/auto`
- `less` настроен на word wrap и использует `lesspipe.sh`, если тот установлен
- подробные комментарии в коде на русском языке, мотивирующие освоить, адаптировать под себя и не забыть основные фишки Zsh и структуру конфига

## Структура репозитория

- `.zshenv` — bootstrap в `HOME`, задаёт `ZDOTDIR`
- `.config/zsh/.zshrc` — точка входа интерактивной сессии
- `.config/zsh/rc.d` — модульные настройки
- `.config/zsh/functions` — функции и autoload-команды
- `.config/zsh/themes/starship` — локальные пресеты Starship

Важно иметь ввиду: изменения, сделанные в `~/.config/zsh/`, остаются лишь в системе. Если нужно зафиксировать эти изменения в своём форке — это нужно сделать отдельно, повторив изменения в `<repo dir>/.config/zsh/`.

## Быстрый старт

Предварительно убедиться, что Zsh установлен. Если нет — установить по инструкции для своей системы. Например:

```bash
# В Ubuntu
sudo apt install zsh

# В Fedora
sudo dnf install zsh
```

В macOS `zsh` используется по умолчанию.

1. Сделать форк репозитория в свой GitHub.
2. Установить зависимости:
   ```bash
   # macOS / Homebrew
   brew install starship fzf lesspipe bat eza
   brew install --cask wezterm
   ```

   Что из этого зачем:

   - `starship` нужен для темы prompt по умолчанию (`starship git-right`)
   - `fzf` нужен для history/file/cd-виджетов из `80-fzf.zsh`
   - `lesspipe` помогает `less` лучше читать архивы и нетекстовые форматы
   - `bat` и `eza` необязательны, но дают хорошие preview-окна в `fzf`
   - `wezterm` необязателен и нужен только для shell integration в самом WezTerm

3. Клонировать форк в любую удобную директорию:
   ```bash
   git clone <your-fork-url> <repo-dir>
   cd <repo-dir>
   ```
4. Запустить полный сценарий (бэкап и установка):
   ```bash
   make all
   ```

`make install` использует `rsync -a --delete`, поэтому `~/.config/zsh` становится точным зеркалом `./.config/zsh` из репозитория. Логика синхронизации сделана намеренно жёсткой (через удаление конфликтов), поэтому в цель `all` включены цели `backup` и `install`.

## Команды Makefile

- `make` или `make all` — полный сценарий: сначала `make backup`, затем `make install`.
- `make install` — копирование с заменой из `./.config/zsh` репозитория → в `~/.config/zsh` и `./.zshenv` → в `~/.zshenv`.
- `make backup` — timestamp-бэкап текущих `~/.config/zsh` и `~/.zshenv`.

Поддерживаются переменные для переопределения путей:

- `ENV` (по умолчанию `$(HOME)/.zshenv`)
- `ZDOTDIR` (по умолчанию `$(HOME)/.config/zsh`)
- `BACKUP_ROOT` (по умолчанию `$(HOME)/.zsh-backup`)

Пример:

```bash
make install ENV=/tmp/demo-zshenv ZDOTDIR=/tmp/demo-zsh
make backup BACKUP_ROOT=/tmp/demo-zsh-backup
```

## Окружение

В конфиге используются функции, рассчитанные на работу в системе автора. В частности, установлены:

- [Throne](https://github.com/throneproj/Throne) — GUI-клиент для VLESS и подобных протоколов с понятной и гибкой настройкой роутинга и локальным SOCKS/HTTP-прокси (функция `proxy` ориентируется на него)
- [yazi](https://yazi-rs.github.io/) — файловый менеджер для терминала

Эти программы можно установить по желанию, а можно не использовать эти функции в `functions/auto`.

## Обновление на новую версию конфига

Рекомендуемый сценарий:

```bash
cd <repo-dir>
git pull
make
```

## Как делать бэкап

Перед установкой/обновлением можно сделать резервную копию:

```bash
make backup
```

По умолчанию бэкап попадает в `~/.zsh-backup/<timestamp>`.

Можно выполнить и вручную, без `make`:

```bash
ts=$(date +%Y%m%d-%H%M%S)
mkdir -p ~/.zsh-backup/$ts
cp -R ~/.config/zsh ~/.zsh-backup/$ts/config-zsh 2>/dev/null || true
cp ~/.zshenv ~/.zsh-backup/$ts/zshenv 2>/dev/null || true
```

## Как это работает

- `~/.zshenv` выставляет `ZDOTDIR=${XDG_CONFIG_HOME:-$HOME/.config}/zsh`
- затем Zsh загружает `$ZDOTDIR/.zshrc`
- `$ZDOTDIR/.zshrc` загружает `rc.d/<NN>-*.zsh` по числовому порядку NN
- модули используют `$ZDOTDIR` для доступа к `rc.d` и `functions`

## Порядок загрузки

- `10-hist.zsh`: история shell
- `20-dirs.zsh`: именованные директории (`hash -d`)
- `30-znap.zsh`: менеджер плагинов Znap
- `40-env.zsh`: `PATH`/`FPATH`, `PAGER`, `LESS`/`LESSOPEN`, `VISUAL`, `EDITOR`, интеграция Homebrew
- `50-prompt.zsh`: prompt через `promptinit`, темы `default` / `pure` / `starship`, helper `prompt-theme`
- `60-plugins.zsh`: список, клонирование и подключение плагинов
- `70-opts.zsh`: shell-опции
- `80-fzf.zsh`: `fzf --zsh`, history/file/cd-виджеты, previews и бинды
- `85-wezterm.zsh`: shell integration WezTerm только внутри самого WezTerm
- `90-keys.zsh`: горячие клавиши и Zsh-виджеты
- `100-commands.zsh`: функции, алиасы, autoload-команды

## Темы prompt

Конфиг использует встроенную систему Zsh `prompt` и добавляет к ней:

- built-in темы Zsh (`prompt default`, `prompt adam1`, ...)
- `Pure`
- `Starship` с локальными пресетами

Если `starship` не установлен, конфиг автоматически деградирует до `prompt pure`. Если недоступен и `Pure`, используется built-in `prompt default`.

Полезные команды:

```bash
prompt -l
prompt -p
prompt pure
prompt starship
prompt starship git-right
prompt starship minimal
prompt starship nerd
prompt-theme list
prompt-theme preview starship:nerd
```

Пресеты Starship лежат в `.config/zsh/themes/starship/*.toml`.

## FZF

Модуль `80-fzf.zsh` подключается только если бинарник `fzf` установлен. Используется `fzf --zsh`, а trigger для completion задан как `,,`, потому что `**` используется для recursive glob. 

Стрелка вверх открывает общее history-меню `hist-fzf-widget`. `Ctrl-X c` открывает fuzzy-переход по каталогам.

Если есть `bat` и `eza`, они используются для preview файлов и директорий

## WezTerm

Модуль `85-wezterm.zsh` ничего не делает вне WezTerm. Внутри WezTerm он подключает официальный `wezterm.sh`. Это даёт prompt marks, актуальный `cwd` для новых вкладок и pane user vars для дальнейшей кастомизации tab/status.

## Встроенные autoload-команды

Команды из `functions/auto` подхватываются автоматически через `$fpath`.

### `proxy`

```bash
proxy on [url]
proxy off
```

Команда рассчитана под установленный Throne (nekoray), который поднимает локальный прокси. В новой сессии терминала прокси выключен — переменные не экспортированы.

При `on` выставляет `ALL_PROXY`, `HTTPS_PROXY`, `HTTP_PROXY`, `NO_PROXY`. Если `url` не передан, используется `http://127.0.0.1:2080` (так в Throne по умолчанию).

Нужно учитывать, что можно выставить и `socks5h`, если HTTP-прокси по каким-либо причинам не подходит, но тогда могут быть проблемы с установкой зависимостей через `pip/pipx`, который будет требовать установленный модуль для работы с SOCKS5. А HTTP-прокси работает «из коробки», но не во всех случаях. Вопрос требует дополнительного исследования.

### `yy`

```bash
yy [args...]
```

Обёртка для файлового менеджера `yazi`: после выхода из `yazi` shell переходит в каталог, на котором вы остановились.

### `extract-images`

`.config/zsh/functions/extract-images` — пример autoload-функции на Zsh и работы с массивом `reply`.

## Полезные алиасы

Если установлен `eza`, конфиг подменяет базовый листинг файлов на более
информативный набор алиасов:

- `ls` — обычный список файлов с директориями в начале и auto-icons
- `l` — по одному пути на строку
- `ll` — длинный список с header и Git-статусом
- `la` — длинный список со скрытыми файлами
- `lt` — дерево каталогов глубиной 2
- `lta` — дерево глубиной 2 со скрытыми файлами
- `tree` — полное дерево через `eza --tree`

## Где хранятся данные

- конфиг: `${XDG_CONFIG_HOME:-~/.config}/zsh`
- плагины и Znap: `${XDG_DATA_HOME:-~/.local/share}/zsh`
- история:
  - macOS + iCloud (если доступно) позволяет иметь синхронную историю между всеми Mac: `~/Library/Mobile Documents/com~apple~CloudDocs/zsh_history`
  - иначе: `${XDG_DATA_HOME:-~/.local/share}/zsh/history`

## Политика зависимостей

- Homebrew не ставится автоматически при старте shell
- интеграция с Homebrew включается только если `brew` уже установлен
- автоклонирование Znap безопасно деградирует:
  - shell не падает, если нет `git`
  - выводится предупреждение, работа продолжается
- `znap` не устанавливает внешние бинарники, поэтому `starship`, `fzf`, `bat`, `eza`, `lesspipe` и `wezterm` ставятся отдельно через менеджер пакетов системы

## Troubleshooting

### `zsh: error: missing .../rc.d`

Конфиг синхронизирован не полностью. Выполните повторно:

```bash
make install
```

Fallback без `make`:

```bash
rsync -a --delete ./.config/zsh/ ~/.config/zsh/
cp ./.zshenv ~/.zshenv
```

### `znap` не скачался

Если нет `git` или сети, `30-znap.zsh` покажет предупреждение и продолжит запуск shell.
Проверьте `git --version` и доступ к GitHub.

### `brew` не установлен

Это нормально. Конфиг работает без Homebrew, просто не включает brew-специфичные пути и handler'ы.

### `fzf` не установлен

Это тоже нормально. Shell стартует без ошибок, просто `80-fzf.zsh` не подключит fuzzy-виджеты истории, файлов и каталогов.

### WezTerm не используется

Это штатный сценарий. `85-wezterm.zsh` проверяет окружение и вне WezTerm сразу завершает работу.
