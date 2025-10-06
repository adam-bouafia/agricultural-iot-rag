#!/bin/bash

# Quick Start Script for Agricultural IoT RAG System

echo "🚀 Agricultural IoT RAG System - Quick Start"
echo "============================================"
echo ""

# Start infrastructure services
echo "1️⃣  Starting infrastructure services..."
docker-compose up -d qdrant mosquitto postgres redis

echo "Waiting for services to be ready..."
sleep 10

# Check if Ollama should be started (optional, requires GPU)
read -p "Do you want to start Ollama? (requires GPU) [y/N]: " start_ollama
if [[ $start_ollama =~ ^[Yy]$ ]]; then
    echo "Starting Ollama..."
    docker-compose up -d ollama
    sleep 5
    
    echo ""
    echo "2️⃣  Pulling Ollama models..."
    echo "This may take a while on first run..."
    docker exec agricultural-iot-rag-ollama-1 ollama pull llama3.2
    docker exec agricultural-iot-rag-ollama-1 ollama pull nomic-embed-text
fi

echo ""
echo "3️⃣  Starting monitoring services..."
docker-compose up -d prometheus grafana influxdb

echo ""
echo "✅ Infrastructure is ready!"
echo ""
echo "Services running:"
echo "  • Qdrant (Vector DB):    http://localhost:6333"
echo "  • MQTT Broker:           tcp://localhost:1883"
echo "  • PostgreSQL:            localhost:5432"
echo "  • Redis:                 localhost:6379"
echo "  • Prometheus:            http://localhost:9090"
echo "  • Grafana:               http://localhost:3000 (admin/admin)"
echo "  • InfluxDB:              http://localhost:8086"
if [[ $start_ollama =~ ^[Yy]$ ]]; then
    echo "  • Ollama:                http://localhost:11434"
fi

echo ""
echo "📝 Next steps:"
echo "  1. Build and run the application:"
echo "     chmod +x scripts/setup.sh && ./scripts/setup.sh"
echo "     ./bin/server"
echo ""
echo "  2. (Optional) Populate knowledge base:"
echo "     ./bin/cli add-knowledge"
echo ""
echo "  3. (Optional) Simulate sensors:"
echo "     python3 scripts/simulate_sensors.py"
echo ""
echo "  4. Test the API:"
echo "     chmod +x scripts/test_api.sh && ./scripts/test_api.sh"
echo ""
