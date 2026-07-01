.PHONY: setup help

setup:
	@chmod +x setup.sh
	@./setup.sh

help:
	@echo "Available targets:"
	@echo "  make setup   — Install and configure everything"