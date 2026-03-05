Модульный конфиг Zsh для macOS + Homebrew и Ubuntu + Linuxbrew.

## Ключевые особенности

- модульная структура с предсказуемым порядком загрузки (`rc.d`)
- единая модель кастомизации: правки делаются прямо в модулях `rc.d/*`
- установка и бэкап существующей конфигурации через Make
- минималистичный prompt (`.config/zsh/functions/prompt_launchpad_setup`) и вывод текущей директории только при смене (`.config/zsh/functions/prompt_launchpad_chpwd`)
- готовый набор плагинов + автоинициализация Znap
- автозагружаемые функции из `.config/zsh/functions/auto`
- подробные комментарии в коде на русском языке, мотивирующие освоить, адаптировать под себя и не забыть основные фишки Zsh и структуру конфига

## Структура репозитория

- `.zshenv` — bootstrap в `HOME`, задаёт `ZDOTDIR`
- `.config/zsh/.zshrc` — точка входа интерактивной сессии
- `.config/zsh/rc.d` — модульные настройки
- `.config/zsh/functions` — функции и autoload-команды

## Быстрый старт

1. Сделать форк репозитория в свой GitHub.
2. Клонировать форк в любую удобную директорию:
```bash
git clone <your-fork-url> <repo-dir>
cd <repo-dir>
```
3. Запустить полный сценарий (бэкап и установка):
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

- `01-hist.zsh`: история shell
- `02-dirs.zsh`: именованные директории (`hash -d`)
- `03-znap.zsh`: менеджер плагинов Znap
- `04-env.zsh`: `PATH`/`FPATH`, `PAGER`, `VISUAL`, `EDITOR`, интеграция Homebrew
- `05-prompt.zsh`: инициализация prompt
- `06-plugins.zsh`: список, клонирование и подключение плагинов
- `07-opts.zsh`: shell-опции
- `08-keys.zsh`: горячие клавиши и Zsh-виджеты
- `09-commands.zsh`: функции, алиасы, autoload-команды

## Рекомендации по кастомизация через форк

1. Держать `main` синхронизированным с `upstream`.
2. Большие эксперименты делать в отдельных ветках — даст возможность быстро переключать ветки для нового/старого поведения и влить в `main`, если всё хорошо.

## Встроенные autoload-команды

Команды из `functions/auto` подхватываются автоматически через `$fpath`.

### `proxy`

```bash
proxy on [url]
proxy off
```

Команда рассчитана под установленный Throne (nekoray), который поднимает локальный прокси.
При `on` выставляет `ALL_PROXY`, `HTTPS_PROXY`, `HTTP_PROXY`, `NO_PROXY`.
Если `url` не передан, используется `http://127.0.0.1:2080` (так в Throne по умолчанию).

Нужно учитывать, что можно выставить и `socks5h`, если HTTP-прокси по каким-либо причинам не подходит, но тогда могут быть проблемы с установкой зависимостей через `pip/pipx`, который будет требовать установленный модуль для работы с SOCKS5. А HTTP-прокси работает «из коробки», но не во всех случаях. Вопрос требует дополнительного исследования.

### `yy`

```bash
yy [args...]
```

Обёртка для файлового менеджера `yazi`: после выхода из `yazi` shell переходит в каталог, на котором вы остановились.

### `extract-images`

`.config/zsh/functions/extract-images` — пример autoload-функции на Zsh и работы с массивом `reply`.

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

Если нет `git` или сети, `03-znap.zsh` покажет предупреждение и продолжит запуск shell.
Проверьте `git --version` и доступ к GitHub.

### `brew` не установлен

Это нормально. Конфиг работает без Homebrew, просто не включает brew-специфичные пути и handler'ы.

## Благодарности

- `marlonrichert` за оригинальный [Launchpad](https://github.com/marlonrichert/zsh-launchpad) и вдохновение
