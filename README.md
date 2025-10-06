# Agricultural IoT RAG System

A production-ready agricultural IoT system with RAG (Retrieval-Augmented Generation) capabilities built with Go.

## Features

- **IoT Sensor Data Collection**: Real-time data from agricultural sensors via MQTT
- **RAG System**: Intelligent knowledge retrieval using vector embeddings
- **LLM Integration**: Local LLM deployment with Ollama
- **Decision Support**: AI-powered agricultural recommendations
- **Time-Series Storage**: Efficient sensor data storage with InfluxDB
- **Vector Database**: Fast similarity search with Qdrant
- **REST API**: HTTP endpoints for all operations
- **Monitoring**: Prometheus metrics for observability

## Prerequisites

- Go 1.21 or higher
- Docker and Docker Compose
- Ollama (for local LLM)

## Quick Start

1. **Clone and setup**:
```bash
cd agricultural-iot-rag
go mod download
```

2. **Start infrastructure with Docker Compose**:
```bash
docker-compose up -d
```

3. **Run the server**:
```bash
go run cmd/server/main.go
```

4. **Test the API**:
```bash
curl http://localhost:8080/health
```

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

## API Endpoints

- `GET /health` - Health check
- `POST /api/v1/decision` - Get agricultural recommendations
- `GET /api/v1/sensors/:field_id` - Get sensor data for a field
- `POST /api/v1/sensors/data` - Receive sensor data
- `GET /metrics` - Prometheus metrics

## Configuration

Environment variables:
- `PORT` - Server port (default: 8080)
- `QDRANT_URL` - Qdrant server URL
- `OLLAMA_URL` - Ollama server URL
- `MQTT_BROKER` - MQTT broker address
- `EMBEDDING_API_URL` - Embedding service URL
- `EMBEDDING_MODEL` - Embedding model name
- `LLM_MODEL` - LLM model name

## Development

Run tests:
```bash
go test ./...
```

Build:
```bash
go build -o server cmd/server/main.go
```

## Deployment

See `deployments/docker-compose.yml` for complete deployment configuration.

## License

MIT
