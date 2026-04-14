.PHONY: help setup clean build run test format analyze

help:
	@echo "SHG Customer App - Available Commands"
	@echo "====================================="
	@echo "make setup          - Install dependencies and generate code"
	@echo "make clean          - Clean build artifacts"
	@echo "make get            - Get dependencies"
	@echo "make build          - Generate code (build_runner)"
	@echo "make build-clean    - Re-generate code"
	@echo "make run            - Run the app"
	@echo "make run-android    - Run on Android"
	@echo "make run-ios        - Run on iOS"
	@echo "make run-web        - Run on Web"
	@echo "make test           - Run tests"
	@echo "make format         - Format code"
	@echo "make analyze        - Analyze code"
	@echo "make doctor         - Check Flutter setup"
	@echo "make build-apk      - Build Android APK"
	@echo "make build-aab      - Build Android App Bundle"
	@echo "make build-ios-app  - Build iOS app"

setup: get build

get:
	flutter pub get

clean:
	flutter clean

build:
	flutter pub run build_runner build --delete-conflicting-outputs

build-clean:
	flutter pub run build_runner clean
	flutter pub run build_runner build --delete-conflicting-outputs

run:
	flutter run

run-android:
	flutter run -d android

run-ios:
	flutter run -d ios

run-web:
	flutter run -d web

test:
	flutter test

format:
	flutter format lib/ test/

analyze:
	flutter analyze

doctor:
	flutter doctor

build-apk:
	flutter build apk --release

build-aab:
	flutter build appbundle --release

build-ios-app:
	flutter build ios --release

# Watch for changes and rebuild
watch:
	flutter pub run build_runner watch

# Generate coverage
coverage:
	flutter test --coverage

# Get detailed package info
packages:
	flutter pub deps --style list

# Output all available commands
list-commands:
	flutter
