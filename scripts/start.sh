#!/bin/bash

# Full System Restart Script
# This script stops everything, rebuilds, and starts fresh

set -e  # Exit on any error

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     🔄 FULL SYSTEM START - Agricultural IoT RAG System      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step 1: Stop all services
echo -e "${YELLOW}[1/8]${NC} Stopping all Docker services..."
docker compose down 2>/dev/null || true
echo -e "${GREEN}✅ Services stopped${NC}"
echo ""

# Step 2: Clean build artifacts
echo -e "${YELLOW}[2/8]${NC} Cleaning build artifacts..."
rm -rf bin/*
echo -e "${GREEN}✅ Build artifacts cleaned${NC}"
echo ""

# Step 3: Build Go applications
echo -e "${YELLOW}[3/8]${NC} Building Go applications..."
make build
echo -e "${GREEN}✅ Go applications built${NC}"
echo ""

# Step 4: Start Docker services
echo -e "${YELLOW}[4/8]${NC} Starting Docker services..."
docker compose up -d
echo -e "${GREEN}✅ Docker services starting${NC}"
echo ""

# Step 5: Wait for services to be ready
echo -e "${YELLOW}[5/8]${NC} Waiting for services to initialize (30 seconds)..."
sleep 10
echo -e "${BLUE}   ⏳ 10 seconds...${NC}"
sleep 10
echo -e "${BLUE}   ⏳ 20 seconds...${NC}"
sleep 10
echo -e "${BLUE}   ⏳ 30 seconds...${NC}"
echo -e "${GREEN}✅ Services should be ready${NC}"
echo ""

# Step 6: Download LLM models
echo -e "${YELLOW}[6/8]${NC} Downloading LLM models (this may take a few minutes)..."
echo -e "${BLUE}   📥 Downloading llama3.2 (~2GB)...${NC}"
docker exec agricultural-iot-rag-ollama-1 ollama pull llama3.2
echo -e "${BLUE}   📥 Downloading nomic-embed-text (~274MB)...${NC}"
docker exec agricultural-iot-rag-ollama-1 ollama pull nomic-embed-text
echo -e "${GREEN}✅ LLM models downloaded${NC}"
echo ""

# Step 7: Start Go server in background
echo -e "${YELLOW}[7/8]${NC} Starting Go application server..."
if [ -f .env ]; then
    export $(cat .env | xargs)
fi
nohup ./bin/server > server.log 2>&1 &
SERVER_PID=$!
echo $SERVER_PID > server.pid
sleep 5
echo -e "${GREEN}✅ Server started (PID: $SERVER_PID)${NC}"
echo -e "${BLUE}   📝 Logs: tail -f server.log${NC}"
echo ""

# Step 8: Populate knowledge base
echo -e "${YELLOW}[8/8]${NC} Populating agricultural knowledge base..."
./scripts/populate_knowledge.sh
echo -e "${GREEN}✅ Knowledge base populated${NC}"
echo ""

# Verify everything is running
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    ✅ SYSTEM STATUS CHECK                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${BLUE}🐳 Docker Services:${NC}"
docker compose ps
echo ""

echo -e "${BLUE}🔍 Service Health Checks:${NC}"
echo -n "   • Qdrant (6333): "
curl -s http://localhost:6333/healthz > /dev/null && echo -e "${GREEN}✅ UP${NC}" || echo -e "❌ DOWN"
echo -n "   • Ollama (11434): "
curl -s http://localhost:11434/api/tags > /dev/null && echo -e "${GREEN}✅ UP${NC}" || echo -e "❌ DOWN"
echo -n "   • Prometheus (9090): "
curl -s http://localhost:9090/-/healthy > /dev/null && echo -e "${GREEN}✅ UP${NC}" || echo -e "❌ DOWN"
echo -n "   • Grafana (3000): "
curl -s http://localhost:3000/api/health > /dev/null && echo -e "${GREEN}✅ UP${NC}" || echo -e "❌ DOWN"
echo -n "   • Go Server (8081): "
curl -s http://localhost:8081/health > /dev/null && echo -e "${GREEN}✅ UP${NC}" || echo -e "❌ DOWN"
echo ""

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    🎉 SYSTEM READY! 🎉                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}Access URLs:${NC}"
echo "   • API:        http://localhost:8081"
echo "   • Health:     http://localhost:8081/health"
echo "   • Metrics:    http://localhost:8081/metrics"
echo "   • Grafana:    http://localhost:3000 (admin/admin)"
echo "   • Prometheus: http://localhost:9090"
echo "   • Qdrant UI:  http://localhost:6333/dashboard"
echo ""
echo -e "${BLUE}📖 Next Steps:${NC}"
echo "   1. Test AI decision endpoint:"
echo "      curl -X POST http://localhost:8081/api/v1/decision \\"
echo "        -H 'Content-Type: application/json' \\"
echo "        -d '{\"query\":\"Should I irrigate?\",\"field_id\":\"field_001\",\"sensor_data\":{\"soil_moisture\":35}}'"
echo ""
echo "   2. Set up Grafana dashboards:"
echo "      See: GRAFANA_SETUP.md"
echo ""
echo "   3. View server logs:"
echo "      tail -f server.log"
echo ""
echo -e "${YELLOW}⚠️  To stop everything:${NC}"
echo "   ./scripts/stop.sh"
echo ""
