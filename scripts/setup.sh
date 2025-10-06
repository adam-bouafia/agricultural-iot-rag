#!/bin/bash

# Setup script for Agricultural IoT RAG System

echo "🌾 Agricultural IoT RAG System Setup"
echo "===================================="

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "❌ Go is not installed. Please install Go 1.21 or higher."
    echo "   Visit: https://go.dev/doc/install"
    exit 1
fi

echo "✓ Go version: $(go version)"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "⚠️  Docker is not installed. You'll need it for infrastructure services."
    echo "   Visit: https://docs.docker.com/get-docker/"
else
    echo "✓ Docker is installed"
fi

# Download dependencies
echo ""
echo "📦 Downloading Go dependencies..."
go mod download
go mod tidy

if [ $? -eq 0 ]; then
    echo "✓ Dependencies downloaded successfully"
else
    echo "❌ Failed to download dependencies"
    exit 1
fi

# Build the applications
echo ""
echo "🔨 Building applications..."

echo "Building server..."
go build -o bin/server cmd/server/main.go
if [ $? -eq 0 ]; then
    echo "✓ Server built successfully"
else
    echo "❌ Failed to build server"
    exit 1
fi

echo "Building CLI..."
go build -o bin/cli cmd/cli/main.go
if [ $? -eq 0 ]; then
    echo "✓ CLI built successfully"
else
    echo "❌ Failed to build CLI"
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo ""
    echo "📝 Creating .env file..."
    cat > .env << 'EOF'
PORT=8080
QDRANT_URL=localhost:6334
OLLAMA_URL=http://localhost:11434
MQTT_BROKER=tcp://localhost:1883
EMBEDDING_API_URL=http://localhost:11434
EMBEDDING_MODEL=nomic-embed-text
LLM_MODEL=llama3.2
POSTGRES_DSN=host=localhost user=postgres password=password dbname=agricultural_iot port=5432 sslmode=disable
REDIS_URL=localhost:6379
EOF
    echo "✓ .env file created"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Start infrastructure: docker-compose up -d"
echo "2. Pull Ollama models:"
echo "   docker exec -it agricultural-iot-rag-ollama-1 ollama pull llama3.2"
echo "   docker exec -it agricultural-iot-rag-ollama-1 ollama pull nomic-embed-text"
echo "3. Add knowledge to vector store: ./bin/cli add-knowledge"
echo "4. Start the server: ./bin/server"
echo "5. Test the API: curl http://localhost:8080/health"
echo ""
echo "For more information, see README.md"
