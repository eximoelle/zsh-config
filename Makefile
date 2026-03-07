#!/usr/bin/make -f
# Используем zsh для всех команд в рецептах.
SHELL = /bin/zsh

# Выполняем все строки одного рецепта в одном shell-процессе.
.ONESHELL:
# Явно помечаем цели без одноимённых файлов.
.PHONY: all install backup

# Путь к целевому .zshenv (можно переопределить через ENV=...).
# ?= – присвоить переменной это значение только если ещё не задано (если уже передали с командой что-то — значение не перезаписывается)
ENV ?= $(HOME)/.zshenv
# Каталог zsh-конфигурации пользователя (можно переопределить через ZDOTDIR=...).
ZDOTDIR ?= $(HOME)/.config/zsh
# Корень для каталогов резервных копий (можно переопределить через BACKUP_ROOT=...).
BACKUP_ROOT ?= $(HOME)/.zsh-backup

# Цель по умолчанию: сначала резервное копирование, затем установка конфигурации.
# В старом варианте было два явных подпроцесса make, поэтому печаталось /usr/bin/make backup и т.д.
# Новый вариант: декларативные зависимости без рекурсивного вызова make, стало тише в терминале
all: backup install

# Устанавливает .zshenv и синхронизирует содержимое .config/zsh в ZDOTDIR.
# @ перед командой – опция make, не печатает саму команду перед запуском, таким образом глушится лишний "мусор"
# и на экране остаются только сообщения print/printf
# set — установка опций shell: e – прерывать выполнение при ошибке команды, u – считать ошибкой обращение к 
# неинициализированной переменной 
# [[ ... ]] – условие в zsh
# -t 1 – проверяет, что файловый дескриптор 1 (stdout) подключён к TTY
# Если true – включаем ANSI-раскраску вывода (на экран), если false – редирект в файл, pipe, CI – цвета отключаем
install:
	@set -eu; \
	if [[ -t 1 ]]; then \
	  c_path=$$'\033[1;34m'; \
	  c_reset=$$'\033[0m'; \
	else \
	  c_path=''; \
	  c_reset=''; \
	fi; \
	[[ -f ./.zshenv ]] || { print -u2 -- "error: missing ./.zshenv in repository root"; exit 1; }; \
	[[ -f ./.config/zsh/.zshrc ]] || { print -u2 -- "error: missing ./.config/zsh/.zshrc in repository"; exit 1; }; \
	command -v rsync >/dev/null 2>&1 || { print -u2 -- "error: rsync is required for 'make install'"; exit 1; }; \
	mkdir -p "$$(dirname "$(ENV)")" "$(ZDOTDIR)"; \
	rsync -a --delete ./.config/zsh/ "$(ZDOTDIR)/"; \
	cp ./.zshenv "$(ENV)"; \
	print -- "Installed zsh config:"; \
	printf '  ENV=%b%s%b\n' "$$c_path" "$(ENV)" "$$c_reset"; \
	printf '  ZDOTDIR=%b%s%b\n' "$$c_path" "$(ZDOTDIR)" "$$c_reset"

# Создаёт резервную копию текущих ZDOTDIR и ENV в каталог с временной меткой.
backup:
	@set -eu; \
	if [[ -t 1 ]]; then \
	  c_path=$$'\033[1;34m'; \
	  c_reset=$$'\033[0m'; \
	else \
	  c_path=''; \
	  c_reset=''; \
	fi; \
	ts="$$(date +%Y%m%d-%H%M%S)"; \
	backup_dir="$(BACKUP_ROOT)/$$ts"; \
	mkdir -p "$$backup_dir"; \
	if [[ -d "$(ZDOTDIR)" ]]; then \
	  cp -R "$(ZDOTDIR)" "$$backup_dir/config-zsh"; \
	  printf 'Backed up %b%s%b -> %b%s%b\n' "$$c_path" "$(ZDOTDIR)" "$$c_reset" "$$c_path" "$$backup_dir/config-zsh" "$$c_reset"; \
	else \
	  printf 'Skip: %b%s%b not found\n' "$$c_path" "$(ZDOTDIR)" "$$c_reset"; \
	fi; \
	if [[ -f "$(ENV)" ]]; then \
	  cp "$(ENV)" "$$backup_dir/zshenv"; \
	  printf 'Backed up %b%s%b -> %b%s%b\n' "$$c_path" "$(ENV)" "$$c_reset" "$$c_path" "$$backup_dir/zshenv" "$$c_reset"; \
	else \
	  printf 'Skip: %b%s%b not found\n' "$$c_path" "$(ENV)" "$$c_reset"; \
	fi; \
	printf 'Backup directory: %b%s%b\n' "$$c_path" "$$backup_dir" "$$c_reset"
