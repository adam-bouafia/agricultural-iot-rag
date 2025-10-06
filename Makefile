.PHONY: help build run test clean docker-up docker-down setup install-deps

# Default target
help:
	@echo "🌾 Agricultural IoT RAG System - Available Commands"
	@echo "=================================================="
	@echo ""
	@echo "Setup & Installation:"
	@echo "  make setup          - Complete project setup"
	@echo "  make install-deps   - Install Go dependencies"
	@echo ""
	@echo "Build:"
	@echo "  make build          - Build all binaries"
	@echo "  make build-server   - Build server only"
	@echo "  make build-cli      - Build CLI only"
	@echo ""
	@echo "Run:"
	@echo "  make run            - Run the server"
	@echo "  make run-cli        - Run CLI help"
	@echo "  make docker-up      - Start all services with Docker"
	@echo "  make docker-down    - Stop all services"
	@echo ""
	@echo "Testing:"
	@echo "  make test           - Run all tests"
	@echo "  make test-api       - Test API endpoints"
	@echo ""
	@echo "Development:"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make fmt            - Format code"
	@echo "  make lint           - Run linter"
	@echo ""
	@echo "Knowledge Base:"
	@echo "  make add-knowledge  - Populate knowledge base"
	@echo "  make search QUERY='your query' - Search knowledge"
	@echo ""
	@echo "Utilities:"
	@echo "  make logs           - Show Docker logs"
	@echo "  make ps             - Show running services"
	@echo ""

# Setup
setup:
	@echo "🔧 Setting up project..."
	@./scripts/setup.sh

install-deps:
	@echo "📦 Installing dependencies..."
	@go mod download
	@go mod tidy

# Build
build: build-server build-cli
	@echo "✅ Build complete!"

build-server:
	@echo "🔨 Building server..."
	@mkdir -p bin
	@go build -o bin/server cmd/server/main.go

build-cli:
	@echo "🔨 Building CLI..."
	@mkdir -p bin
	@go build -o bin/cli cmd/cli/main.go

# Run
run: build-server
	@echo "🚀 Starting server..."
	@./bin/server

run-cli: build-cli
	@./bin/cli

# Docker
docker-up:
	@echo "🐳 Starting Docker services..."
	@docker compose up -d
	@echo "✅ Services started!"
	@echo "⏳ Waiting for services to be ready..."
	@sleep 10
	@make ps

docker-down:
	@echo "🛑 Stopping Docker services..."
	@docker compose down

docker-logs:
	@docker compose logs -f

ps:
	@echo "📊 Running services:"
	@docker compose ps

# Testing
test:
	@echo "🧪 Running tests..."
	@go test -v ./...

test-api:
	@echo "🧪 Testing API endpoints..."
	@./scripts/test_api.sh

test-integration:
	@echo "🧪 Running integration tests..."
	@go test -v ./test/...

# Knowledge Base
add-knowledge: build-cli
	@echo "📚 Adding knowledge to vector store..."
	@./bin/cli add-knowledge

search: build-cli
	@./bin/cli search "$(QUERY)"

# Development
fmt:
	@echo "🎨 Formatting code..."
	@go fmt ./...

lint:
	@echo "🔍 Running linter..."
	@golangci-lint run || echo "golangci-lint not installed, skipping..."

vet:
	@echo "🔍 Running go vet..."
	@go vet ./...

# Clean
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf bin/
	@rm -f server cli
	@echo "✅ Clean complete!"

# Ollama setup
ollama-pull:
	@echo "📥 Pulling Ollama models..."
	@docker exec agricultural-iot-rag-ollama-1 ollama pull llama3.2
	@docker exec agricultural-iot-rag-ollama-1 ollama pull nomic-embed-text
	@echo "✅ Models downloaded!"

ollama-list:
	@docker exec agricultural-iot-rag-ollama-1 ollama list

# Monitoring
metrics:
	@echo "📊 Opening Prometheus..."
	@xdg-open http://localhost:9090 2>/dev/null || open http://localhost:9090 2>/dev/null || echo "Open http://localhost:9090 in your browser"

grafana:
	@echo "📊 Opening Grafana..."
	@xdg-open http://localhost:3000 2>/dev/null || open http://localhost:3000 2>/dev/null || echo "Open http://localhost:3000 in your browser (admin/admin)"

# Full startup
start-all: docker-up ollama-pull build add-knowledge
	@echo ""
	@echo "✅ Full system started!"
	@echo ""
	@echo "🌐 Services:"
	@echo "  • API:        http://localhost:8080"
	@echo "  • Qdrant:     http://localhost:6333"
	@echo "  • Prometheus: http://localhost:9090"
	@echo "  • Grafana:    http://localhost:3000 (admin/admin)"
	@echo ""
	@echo "🚀 Start server: make run"
	@echo ""

# Quick test
quick-test: build test-api
	@echo "✅ Quick test complete!"

# Production build
build-prod:
	@echo "🏗️  Building for production..."
	@CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-w -s" -o bin/server cmd/server/main.go
	@CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-w -s" -o bin/cli cmd/cli/main.go
	@echo "✅ Production build complete!"

# Install project globally
install: build-prod
	@echo "📦 Installing binaries..."
	@sudo cp bin/server /usr/local/bin/agri-server
	@sudo cp bin/cli /usr/local/bin/agri-cli
	@echo "✅ Installed! Use 'agri-server' and 'agri-cli'"

# Show status
status:
	@echo "📊 System Status"
	@echo "================"
	@echo ""
	@echo "Docker Services:"
	@docker-compose ps
	@echo ""
	@echo "API Health:"
	@curl -s http://localhost:8080/health | jq '.' 2>/dev/null || echo "Server not running"
