# BMI Tracker Makefile

.PHONY: help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: setup
setup: ## Initial project setup
	flutter pub get
	cd ios && pod install

.PHONY: clean
clean: ## Clean build artifacts
	flutter clean
	cd ios && pod deintegrate
	rm -rf build/
	rm -rf .dart_tool/
	rm -rf .packages

.PHONY: get
get: ## Get dependencies
	flutter pub get

.PHONY: analyze
analyze: ## Analyze code
	flutter analyze

.PHONY: format
format: ## Format code
	dart format lib/ test/

.PHONY: test
test: ## Run tests
	flutter test

.PHONY: test-coverage
test-coverage: ## Run tests with coverage
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html
	open coverage/html/index.html

.PHONY: run
run: ## Run app in debug mode
	flutter run

.PHONY: run-release
run-release: ## Run app in release mode
	flutter run --release

.PHONY: build-apk
build-apk: ## Build Android APK
	flutter build apk --release

.PHONY: build-appbundle
build-appbundle: ## Build Android App Bundle
	flutter build appbundle --release

.PHONY: build-ios
build-ios: ## Build iOS app
	flutter build ios --release

.PHONY: build-ipa
build-ipa: ## Build iOS IPA
	flutter build ipa --release

.PHONY: icons
icons: ## Generate app icons
	flutter pub run flutter_launcher_icons

.PHONY: splash
splash: ## Generate splash screen
	flutter pub run flutter_native_splash:create

.PHONY: env-example
env-example: ## Create .env from .env.example
	cp .env.example .env

.PHONY: supabase-init
supabase-init: ## Initialize Supabase locally
	supabase init

.PHONY: supabase-start
supabase-start: ## Start local Supabase
	supabase start

.PHONY: supabase-stop
supabase-stop: ## Stop local Supabase
	supabase stop

.PHONY: migration-new
migration-new: ## Create new migration (usage: make migration-new name=migration_name)
	supabase migration new $(name)

.PHONY: migration-up
migration-up: ## Apply migrations
	supabase db push

.PHONY: check-all
check-all: analyze test ## Run all checks (analyze, test)
	@echo "All checks passed!"