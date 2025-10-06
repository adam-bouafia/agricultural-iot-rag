#!/bin/bash

# First Run Script - Complete Setup and Test

clear
cat << 'EOF'

╔════════════════════════════════════════════════════════════════════╗
║                                                                    ║
║       🌾 Agricultural IoT RAG System - First Run Setup 🌾         ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝

This script will:
  1. Check prerequisites
  2. Start all services
  3. Build the application
  4. Populate knowledge base
  5. Test the system

EOF

echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."
echo ""

# Function to check command exists
check_command() {
    if command -v $1 &> /dev/null; then
        echo "✅ $1 is installed"
        return 0
    else
        echo "❌ $1 is NOT installed"
        return 1
    fi
}

# Step 1: Check Prerequisites
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Step 1: Checking Prerequisites"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

MISSING=0

check_command "docker" || MISSING=1
check_command "docker-compose" || check_command "docker compose" || MISSING=1
check_command "make" || MISSING=1

echo ""

if [ $MISSING -eq 1 ]; then
    echo "⚠️  Some prerequisites are missing. Please install them first."
    echo ""
    echo "Installation guides:"
    echo "  • Docker: https://docs.docker.com/get-docker/"
    echo "  • Make: sudo apt-get install build-essential"
    echo ""
    exit 1
fi

echo "✅ All prerequisites are installed!"
echo ""
read -p "Press Enter to continue..."

# Step 2: Start Docker Services
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🐳 Step 2: Starting Docker Services"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Starting infrastructure services (this may take a few minutes)..."
docker-compose up -d qdrant mosquitto postgres redis influxdb prometheus grafana

if [ $? -ne 0 ]; then
    echo "❌ Failed to start Docker services"
    exit 1
fi

echo ""
echo "✅ Docker services started!"
echo ""
echo "Waiting 15 seconds for services to initialize..."
sleep 15

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  Go is not installed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "To build and run the application, you need Go installed."
    echo ""
    echo "Options:"
    echo "  1. Install Go: https://go.dev/doc/install"
    echo "  2. Or run with Docker: docker-compose up -d app"
    echo ""
    echo "Services are running. You can:"
    echo "  • View Grafana: http://localhost:3000 (admin/admin)"
    echo "  • View Prometheus: http://localhost:9090"
    echo "  • Access Qdrant: http://localhost:6333"
    echo ""
    exit 1
fi

# Step 3: Build Application
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔨 Step 3: Building Application"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Installing Go dependencies..."
go mod download
go mod tidy

echo ""
echo "Building server and CLI..."
make build

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "✅ Build successful!"
echo ""
read -p "Press Enter to continue..."

# Step 4: Populate Knowledge Base
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 Step 4: Populating Knowledge Base (Optional)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "This step requires Ollama to be running with embedding models."
echo ""
read -p "Do you want to populate the knowledge base now? (y/N): " populate_kb

if [[ $populate_kb =~ ^[Yy]$ ]]; then
    echo ""
    echo "Checking if Ollama is available..."
    
    # Check if Ollama service is running
    if docker-compose ps ollama 2>/dev/null | grep -q "Up"; then
        echo "✅ Ollama service is running"
    else
        echo "⚠️  Ollama service is not running"
        read -p "Start Ollama? (requires GPU) (y/N): " start_ollama
        
        if [[ $start_ollama =~ ^[Yy]$ ]]; then
            docker-compose up -d ollama
            sleep 10
            echo "Pulling embedding model (this may take several minutes)..."
            docker exec agricultural-iot-rag-ollama-1 ollama pull nomic-embed-text
        else
            echo "Skipping knowledge base population. You can do this later with:"
            echo "  ./bin/cli add-knowledge"
        fi
    fi
    
    if docker-compose ps ollama 2>/dev/null | grep -q "Up"; then
        echo ""
        echo "Adding agricultural knowledge to vector database..."
        ./bin/cli add-knowledge
        echo ""
        echo "✅ Knowledge base populated!"
    fi
else
    echo "Skipped. You can populate later with: ./bin/cli add-knowledge"
fi

# Step 5: Final Status
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Infrastructure services are running"
echo "✅ Application is built"
echo ""
echo "📊 Running Services:"
docker-compose ps
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Next Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Start the server:"
echo "   $ ./bin/server"
echo ""
echo "2. In another terminal, test the API:"
echo "   $ curl http://localhost:8080/health"
echo ""
echo "3. Or run the test script:"
echo "   $ ./scripts/test_api.sh"
echo ""
echo "4. (Optional) Simulate sensors:"
echo "   $ python3 scripts/simulate_sensors.py"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Available Services"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  • API Server:      http://localhost:8080"
echo "  • Qdrant:          http://localhost:6333"
echo "  • Grafana:         http://localhost:3000 (admin/admin)"
echo "  • Prometheus:      http://localhost:9090"
echo "  • InfluxDB:        http://localhost:8086"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 Documentation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  • QUICKSTART.md     - Quick start guide"
echo "  • README.md         - Full documentation"
echo "  • docs/API.md       - API reference"
echo "  • BUILD_COMPLETE.md - Build summary"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 Useful Commands"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  make help          - Show all make commands"
echo "  make run           - Run the server"
echo "  make test          - Run tests"
echo "  make docker-down   - Stop all services"
echo "  make clean         - Clean build artifacts"
echo ""
echo "✨ Happy farming! 🌾"
echo ""
