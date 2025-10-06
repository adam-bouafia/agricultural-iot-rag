# 🚀 Quick Start Guide

Get the Agricultural IoT RAG System running in 5 minutes!

## Prerequisites Check

```bash
# Check Go installation
go version  # Should be 1.21+

# Check Docker
docker --version
docker-compose --version

# Check Python (for sensor simulator)
python3 --version
```

If any are missing, install them first.

## Option 1: Quick Start (Recommended)

```bash
# 1. Navigate to project
cd /home/neo/Documents/agurotech/agricultural-iot-rag

# 2. Use Makefile for easy setup
make help              # See all commands
make docker-up         # Start infrastructure
make build             # Build applications
make run               # Start server
```

## Option 2: Manual Setup

### Step 1: Start Infrastructure

```bash
# Start all services
docker-compose up -d

# Wait for services to be ready
sleep 10

# Check services are running
docker-compose ps
```

Expected services:
- ✅ Qdrant (Vector Database)
- ✅ Mosquitto (MQTT Broker)
- ✅ PostgreSQL
- ✅ Redis
- ✅ InfluxDB
- ✅ Prometheus
- ✅ Grafana

### Step 2: Setup Ollama (Optional, requires GPU)

```bash
# Start Ollama
docker-compose up -d ollama

# Pull models
docker exec agricultural-iot-rag-ollama-1 ollama pull llama3.2
docker exec agricultural-iot-rag-ollama-1 ollama pull nomic-embed-text
```

### Step 3: Build Application

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run setup script
./scripts/setup.sh

# Or build manually
mkdir -p bin
go build -o bin/server cmd/server/main.go
go build -o bin/cli cmd/cli/main.go
```

### Step 4: Populate Knowledge Base

```bash
# Add agricultural knowledge
./bin/cli add-knowledge

# Test search
./bin/cli search "potato irrigation"
```

### Step 5: Start Server

```bash
# Run the server
./bin/server
```

You should see:
```
✓ Agricultural IoT RAG System is running on http://localhost:8080
✓ Health check: http://localhost:8080/health
✓ Metrics: http://localhost:8080/metrics
✓ API: http://localhost:8080/api/v1/
```

### Step 6: Test API

In a new terminal:

```bash
# Test health
curl http://localhost:8080/health

# Get sensor data
curl http://localhost:8080/api/v1/sensors/field_001

# Get decision (requires Ollama)
curl -X POST http://localhost:8080/api/v1/decision \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Should I irrigate my potato field?",
    "field_id": "field_001"
  }'
```

## Option 3: Using Make Commands

The Makefile provides convenient shortcuts:

```bash
# Complete setup
make start-all         # Does everything automatically!

# Or step by step
make docker-up         # Start services
make build             # Build binaries
make add-knowledge     # Populate knowledge base
make run               # Run server

# Testing
make test              # Run tests
make test-api          # Test API endpoints

# Monitoring
make metrics           # Open Prometheus
make grafana           # Open Grafana
```

## Verify Installation

### Check Services

```bash
# API health
curl http://localhost:8080/health

# Qdrant
curl http://localhost:6333/collections

# Prometheus
curl http://localhost:9090/-/healthy
```

### Check Logs

```bash
# Application logs
# (Check terminal where server is running)

# Docker logs
docker-compose logs -f app
docker-compose logs -f qdrant
docker-compose logs -f mosquitto
```

## Test with Sensor Simulator

```bash
# Install Python dependencies
pip3 install paho-mqtt

# Run simulator (in new terminal)
python3 scripts/simulate_sensors.py
```

You should see sensor data being published to MQTT and processed by the server.

## Access Web Interfaces

| Service | URL | Credentials |
|---------|-----|-------------|
| API | http://localhost:8080 | - |
| Qdrant Dashboard | http://localhost:6333/dashboard | - |
| Grafana | http://localhost:3000 | admin/admin |
| Prometheus | http://localhost:9090 | - |
| InfluxDB | http://localhost:8086 | admin/password123 |

## Common Issues & Solutions

### Issue: "go: command not found"

**Solution:** Install Go from https://go.dev/doc/install

### Issue: "docker: command not found"

**Solution:** Install Docker from https://docs.docker.com/get-docker/

### Issue: Port already in use

**Solution:** 
```bash
# Find process using port
sudo lsof -i :8080

# Kill process or change port in .env
export PORT=8081
```

### Issue: Ollama models not found

**Solution:**
```bash
# Pull models manually
docker exec agricultural-iot-rag-ollama-1 ollama pull llama3.2
docker exec agricultural-iot-rag-ollama-1 ollama pull nomic-embed-text

# Or use without Ollama (some features disabled)
```

### Issue: Cannot connect to Qdrant

**Solution:**
```bash
# Check if Qdrant is running
docker-compose ps qdrant

# Restart Qdrant
docker-compose restart qdrant

# Check logs
docker-compose logs qdrant
```

### Issue: MQTT connection failed

**Solution:**
```bash
# Check Mosquitto is running
docker-compose ps mosquitto

# Restart Mosquitto
docker-compose restart mosquitto

# Test MQTT connection
mosquitto_pub -h localhost -t test -m "hello"
```

## Stopping Services

```bash
# Stop server
Ctrl+C

# Stop Docker services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

## Next Steps

Once everything is running:

1. **Explore the API** - See `docs/API.md` for all endpoints
2. **Add more knowledge** - Edit `cmd/cli/main.go` to add domain knowledge
3. **Customize models** - Change LLM models in `.env`
4. **Set up monitoring** - Configure Grafana dashboards
5. **Deploy to production** - Use `make build-prod` and deploy

## Quick Commands Reference

```bash
# Setup
make setup              # Initial setup
make docker-up          # Start services
make build              # Build apps

# Run
make run                # Start server
make add-knowledge      # Populate KB

# Test
make test               # Run tests
make test-api           # Test API

# Clean
make clean              # Clean builds
make docker-down        # Stop services

# Help
make help               # Show all commands
```

## Getting Help

- Check `README.md` for detailed documentation
- See `docs/API.md` for API reference
- Read `PROJECT_SUMMARY.md` for architecture overview
- Look at example code in `test/` directory

## Success Checklist

- ✅ All Docker services running
- ✅ Server starts without errors
- ✅ Health check returns OK
- ✅ Can get sensor data
- ✅ Knowledge base populated
- ✅ Sensor simulator works
- ✅ API tests pass

If all checked, you're ready to go! 🎉

## Production Deployment

For production:

```bash
# Build optimized binaries
make build-prod

# Use docker-compose for deployment
docker-compose -f docker-compose.yml up -d

# Or build Docker image
docker build -t agri-iot-rag .
docker run -p 8080:8080 agri-iot-rag
```

---

**Need help?** Check the logs, documentation, or configuration files.

**Happy farming! 🌾**
