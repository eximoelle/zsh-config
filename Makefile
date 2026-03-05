#!/usr/bin/make -f
# Используем zsh для всех команд в рецептах.
SHELL = /bin/zsh

# Выполняем все строки одного рецепта в одном shell-процессе.
.ONESHELL:
# Явно помечаем цели без одноимённых файлов.
.PHONY: all install backup

# Путь к целевому .zshenv (можно переопределить через ENV=...).
ENV ?= $(HOME)/.zshenv
# Каталог zsh-конфигурации пользователя (можно переопределить через ZDOTDIR=...).
ZDOTDIR ?= $(HOME)/.config/zsh
# Корень для каталогов резервных копий (можно переопределить через BACKUP_ROOT=...).
BACKUP_ROOT ?= $(HOME)/.zsh-backup

# Цель по умолчанию: сначала резервное копирование, затем установка конфигурации.
all:
	$(MAKE) backup
	$(MAKE) install

# Устанавливает .zshenv и синхронизирует содержимое .config/zsh в ZDOTDIR.
install:
	set -eu; \
	[[ -f ./.zshenv ]] || { print -u2 -- "error: missing ./.zshenv in repository root"; exit 1; }; \
	[[ -f ./.config/zsh/.zshrc ]] || { print -u2 -- "error: missing ./.config/zsh/.zshrc in repository"; exit 1; }; \
	command -v rsync >/dev/null 2>&1 || { print -u2 -- "error: rsync is required for 'make install'"; exit 1; }; \
	mkdir -p "$$(dirname "$(ENV)")" "$(ZDOTDIR)"; \
	rsync -a --delete ./.config/zsh/ "$(ZDOTDIR)/"; \
	cp ./.zshenv "$(ENV)"; \
	print -- "Installed zsh config:"; \
	print -- "  ENV=$(ENV)"; \
	print -- "  ZDOTDIR=$(ZDOTDIR)"

# Создаёт резервную копию текущих ZDOTDIR и ENV в каталог с временной меткой.
backup:
	set -eu; \
	ts="$$(date +%Y%m%d-%H%M%S)"; \
	backup_dir="$(BACKUP_ROOT)/$$ts"; \
	mkdir -p "$$backup_dir"; \
	if [[ -d "$(ZDOTDIR)" ]]; then \
	  cp -R "$(ZDOTDIR)" "$$backup_dir/config-zsh"; \
	  print -- "Backed up $(ZDOTDIR) -> $$backup_dir/config-zsh"; \
	else \
	  print -- "Skip: $(ZDOTDIR) not found"; \
	fi; \
	if [[ -f "$(ENV)" ]]; then \
	  cp "$(ENV)" "$$backup_dir/zshenv"; \
	  print -- "Backed up $(ENV) -> $$backup_dir/zshenv"; \
	else \
	  print -- "Skip: $(ENV) not found"; \
	fi; \
	print -- "Backup directory: $$backup_dir"
