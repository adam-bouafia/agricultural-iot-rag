# 🌾 Agricultural IoT RAG System

> A production-ready agricultural IoT system with RAG (Retrieval-Augmented Generation) capabilities built with Go. Combines real-time sensor data with AI-powered decision support for smart farming.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Go Version](https://img.shields.io/badge/Go-1.22+-00ADD8?logo=go)](https://go.dev/)
[![Docker](https://img.shields.io/badge/Docker-Required-2496ED?logo=docker)](https://www.docker.com/)

## ✨ Features

- 🌡️ **IoT Sensor Data Collection**: Real-time data from agricultural sensors via MQTT
- 🧠 **RAG System**: Intelligent knowledge retrieval using vector embeddings
- 🤖 **LLM Integration**: Local LLM deployment with Ollama (llama3.2)
- 💡 **Decision Support**: AI-powered agricultural recommendations with citations
- 📊 **Time-Series Storage**: Efficient sensor data storage with InfluxDB
- 🔍 **Vector Database**: Fast similarity search with Qdrant
- 🚀 **REST API**: HTTP endpoints for all operations
- 📈 **Monitoring**: Prometheus metrics & Grafana dashboards
- 🐳 **Docker**: Complete containerized deployment
- ⚡ **Production Ready**: Built with Go for performance and reliability

## 📋 Prerequisites

- **Go 1.22+** - [Install Go](https://go.dev/doc/install)
- **Docker & Docker Compose** - [Install Docker](https://docs.docker.com/get-docker/)
- **~4GB RAM** - For LLM models and services
- **~5GB Disk** - For Docker images and models

## 🚀 Quick Start

**One command to start everything:**

```bash
./scripts/start.sh
```

This will:
- Stop any running services
- Build Go applications
- Start all 8 Docker services (Qdrant, Ollama, MQTT, PostgreSQL, Redis, InfluxDB, Prometheus, Grafana)
- Download LLM models (llama3.2, nomic-embed-text)
- Start the Go server on port 8081
- Populate the knowledge base with 50+ agricultural facts

**Expected output:**

```
╔════════════════════════════════════════════════════════════════╗
║            🎉 SYSTEM START COMPLETE! 🎉                        ║
╚════════════════════════════════════════════════════════════════╝

✅ ALL SERVICES RUNNING:

🐳 Docker Services (8):
   ✅ Qdrant      - http://localhost:6333
   ✅ Ollama      - http://localhost:11434
   ✅ Mosquitto   - tcp://localhost:1883
   ✅ PostgreSQL  - localhost:5432
   ✅ Redis       - localhost:6379
   ✅ InfluxDB    - http://localhost:8086
   ✅ Prometheus  - http://localhost:9090
   ✅ Grafana     - http://localhost:3000

🚀 Application:
   ✅ Go Server   - http://localhost:8081

📚 Knowledge Base:
   ✅ 50+ agricultural knowledge items loaded

🤖 LLM Models:
   ✅ llama3.2 (2GB)
   ✅ nomic-embed-text (274MB)
```

### Test the System

```bash
curl -X POST http://localhost:8081/api/v1/decision \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "Should I irrigate my potato field?",
    "field_id": "field_001",
    "sensor_data": {
      "soil_moisture": 35,
      "temperature": 22
    }
  }'
```

**Expected:** AI recommendation with citations from knowledge base

### Access URLs

- **API:** http://localhost:8081
- **Health:** http://localhost:8081/health
- **Metrics:** http://localhost:8081/metrics
- **Grafana:** http://localhost:3000 (admin/admin)
- **Prometheus:** http://localhost:9090
- **Qdrant UI:** http://localhost:6333/dashboard

## Project Structure

```
agricultural-iot-rag/
├── cmd/                    # Application entry points
│   ├── server/            # Main server application
│   ├── worker/            # Background worker
│   └── cli/               # CLI tools
├── internal/              # Private application code
│   ├── config/            # Configuration management
│   ├── handlers/          # HTTP request handlers
│   ├── services/          # Business logic
│   ├── models/            # Data models
│   ├── storage/           # Database connections
│   └── metrics/           # Prometheus metrics
├── pkg/                   # Public libraries
│   ├── iot/              # IoT data collection
│   ├── rag/              # RAG implementation
│   ├── llm/              # LLM client
│   └── cache/            # Caching utilities
├── test/                  # Integration tests
├── deployments/           # Docker and deployment configs
└── docs/                  # Documentation
```

## 📚 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - 5-minute getting started guide
- **[SYSTEM_EXPLANATION.md](SYSTEM_EXPLANATION.md)** - Detailed system architecture
- **[KNOWLEDGE_GUIDE.md](KNOWLEDGE_GUIDE.md)** - How the RAG system works
- **[GRAFANA_SETUP.md](GRAFANA_SETUP.md)** - Monitoring dashboard setup
- **[GRAFANA_WORKING_METRICS.md](GRAFANA_WORKING_METRICS.md)** - Available metrics and panels
- **[DOCS_INDEX.md](DOCS_INDEX.md)** - Complete documentation index

## 📡 API Endpoints

- `GET /health` - Health check
- `GET /metrics` - Prometheus metrics
- `POST /api/v1/decision` - Get AI agricultural recommendations
- `GET /api/v1/sensors/:field_id` - Get sensor data for a field
- `POST /api/v1/sensors/data` - Receive sensor data
- `GET /api/v1/fields/stats` - Get field statistics

## 🛠️ Useful Commands

```bash
# Stop all services
./scripts/stop.sh

# Restart everything
./scripts/restart.sh

# View server logs
tail -f server.log

# Add knowledge to the system
./bin/cli add-knowledge "Your agricultural knowledge here"

# Search the knowledge base
./bin/cli search "potato irrigation"

# Build applications
make build

# Run tests
make test
```

## ⚙️ Configuration

Environment variables (`.env` file):
- `PORT` - Server port (default: 8081)
- `QDRANT_URL` - Qdrant server URL (localhost:6334)
- `OLLAMA_URL` - Ollama server URL (http://localhost:11434)
- `MQTT_BROKER` - MQTT broker address (tcp://localhost:1883)
- `EMBEDDING_API_URL` - Embedding service URL
- `EMBEDDING_MODEL` - Embedding model (nomic-embed-text)
- `LLM_MODEL` - LLM model (llama3.2)
- `POSTGRES_DSN` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string

## 🔧 Development

```bash
# Install dependencies
go mod download

# Run tests
go test ./...

# Build manually
go build -o bin/server cmd/server/main.go
go build -o bin/cli cmd/cli/main.go

# Format code
go fmt ./...

# Lint
golangci-lint run
```

## 🐳 Docker Services

| Service | Port | Purpose |
|---------|------|---------|
| Qdrant | 6333-6334 | Vector database for embeddings |
| Ollama | 11434 | Local LLM inference |
| Mosquitto | 1883, 9001 | MQTT message broker |
| PostgreSQL | 5432 | Relational database |
| Redis | 6379 | Cache layer |
| InfluxDB | 8086 | Time-series sensor data |
| Prometheus | 9090 | Metrics collection |
| Grafana | 3000 | Monitoring dashboards |

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT
