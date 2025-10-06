# 🎓 Complete System Execution Guide
## Step-by-Step Explanation of the Agricultural IoT RAG System

---

## 📖 Table of Contents
1. [System Startup Flow](#1-system-startup-flow)
2. [Data Collection Pipeline](#2-data-collection-pipeline)
3. [RAG System Workflow](#3-rag-system-workflow)
4. [API Request Handling](#4-api-request-handling)
5. [File-by-File Explanation](#5-file-by-file-explanation)
6. [Real-World Scenario](#6-real-world-scenario)

---

## 1. 🚀 System Startup Flow

### **What Happens When You Run `./bin/server`?**

```
┌─────────────────────────────────────────────────────────────────┐
│  STEP 1: Application Entry Point                                │
│  File: cmd/server/main.go                                       │
└─────────────────────────────────────────────────────────────────┘
```

#### **Step 1.1: Load Configuration**
```go
cfg := config.Load()
```

**What it does:**
- Reads environment variables from `.env` or system
- Sets up URLs for all services (Qdrant, Ollama, MQTT, etc.)
- Provides default values if not set

**File:** `internal/config/config.go`

```go
type Config struct {
    Port             string  // API server port (default: 8080)
    QdrantURL        string  // Vector DB address
    OllamaURL        string  // LLM server address
    MQTTBroker       string  // MQTT broker for sensors
    EmbeddingModel   string  // Model for text embeddings
    LLMModel         string  // Language model name
    // ... more configuration
}
```

**Why it matters:** Makes the system configurable without code changes!

---

#### **Step 1.2: Initialize Vector Store**
```go
vectorStore, err := rag.NewVectorStore(cfg.QdrantURL, "agricultural_knowledge")
```

**What it does:**
1. Connects to Qdrant (vector database)
2. Creates/verifies "agricultural_knowledge" collection
3. Sets up 768-dimensional vector space for embeddings

**File:** `pkg/rag/vector_store.go`

**Behind the scenes:**
```go
// Creates a collection to store embeddings
CreateCollection(ctx, &qdrant.CreateCollection{
    CollectionName: "agricultural_knowledge",
    VectorsConfig: &qdrant.VectorsConfig{
        Params: &qdrant.VectorParams{
            Size:     768,        // Vector dimensions
            Distance: Cosine,     // Similarity metric
        },
    },
})
```

**Why it matters:** This is where we store agricultural knowledge as vectors for semantic search!

---

#### **Step 1.3: Initialize Embedding Service**
```go
embeddingService := rag.NewEmbeddingService(cfg.EmbeddingAPIURL, cfg.EmbeddingModel)
```

**What it does:**
- Creates a client to convert text → numbers (embeddings)
- Uses Ollama with "nomic-embed-text" model

**File:** `pkg/rag/embeddings.go`

**Example:**
```
Text: "Potatoes need 60-80% soil moisture"
      ↓ (embedding service)
Vector: [0.234, -0.567, 0.123, ..., 0.891]  (768 numbers)
```

**Why it matters:** Embeddings allow us to find similar knowledge based on meaning, not just keywords!

---

#### **Step 1.4: Create Knowledge Service**
```go
knowledgeService := services.NewKnowledgeService(vectorStore, embeddingService)
```

**What it does:**
- Combines vector store + embeddings
- Provides high-level search functionality
- Enhances queries with sensor context

**File:** `internal/services/knowledge.go`

---

#### **Step 1.5: Initialize LLM Client**
```go
llmClient := llm.NewOllamaClient(cfg.OllamaURL, cfg.LLMModel)
```

**What it does:**
- Connects to Ollama (local LLM server)
- Prepares to use "llama3.2" model
- Ready to generate text responses

**File:** `pkg/llm/ollama.go`

---

#### **Step 1.6: Create HTTP Handlers**
```go
decisionHandler := handlers.NewDecisionHandler(knowledgeService, llmClient)
sensorHandler := handlers.NewSensorHandler()
```

**What it does:**
- Creates objects that handle HTTP requests
- Decision handler: AI recommendations
- Sensor handler: Sensor data management

**Files:**
- `internal/handlers/decision.go`
- `internal/handlers/sensor.go`

---

#### **Step 1.7: Setup HTTP Router**
```go
router := gin.Default()

// Health check
router.GET("/health", healthCheckHandler)

// API routes
api := router.Group("/api/v1")
{
    api.POST("/decision", decisionHandler.GetDecision)
    api.GET("/sensors/:field_id", sensorHandler.GetSensorData)
    api.POST("/sensors/data", sensorHandler.ReceiveSensorData)
}
```

**What it does:**
- Sets up URL paths (routes)
- Maps URLs to handler functions
- Adds middleware (CORS, logging)

---

#### **Step 1.8: Start MQTT Collector (Background)**
```go
dataChan := make(chan models.SensorReading, 100)
mqttCollector := iot.NewMQTTCollector(cfg.MQTTBroker, dataChan)

go func() {
    mqttCollector.Start(ctx)
}()
```

**What it does:**
1. Creates a channel (queue) for sensor data
2. Connects to MQTT broker (Mosquitto)
3. Subscribes to sensor topics
4. Runs in background (goroutine)

**File:** `pkg/iot/mqtt_collector.go`

**Topics subscribed to:**
```
sensors/soil/+/data      # Soil sensors from any field
sensors/weather/+/data   # Weather sensors
sensors/crop/+/data      # Crop monitoring sensors
```

---

#### **Step 1.9: Start Data Processor (Background)**
```go
go processIncomingData(dataChan)
```

**What it does:**
- Reads from the sensor data channel
- Validates data
- Checks for alerts (low moisture, high temperature)
- Could store to time-series database

**Runs continuously in background!**

---

#### **Step 1.10: Start HTTP Server**
```go
server := &http.Server{
    Addr:    ":8080",
    Handler: router,
}

go func() {
    server.ListenAndServe()
}()

log.Printf("Server running on http://localhost:8080")
```

**What it does:**
- Starts listening on port 8080
- Waits for HTTP requests
- Ready to serve API calls!

---

#### **Step 1.11: Wait for Shutdown Signal**
```go
quit := make(chan os.Signal, 1)
signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
<-quit  // Blocks here until Ctrl+C

// Graceful shutdown
server.Shutdown(ctx)
```

**What it does:**
- Waits for Ctrl+C or kill signal
- Gracefully shuts down (finishes current requests)
- Closes connections properly

---

## 2. 📡 Data Collection Pipeline

### **How Sensor Data Flows Through the System**

```
┌─────────────┐
│ IoT Sensor  │ (Physical device in the field)
└──────┬──────┘
       │
       │ (MQTT Protocol)
       ↓
┌──────────────────────────────────────────────────────┐
│ MQTT Broker (Mosquitto)                              │
│ Topic: sensors/soil/field_001/data                   │
└──────┬───────────────────────────────────────────────┘
       │
       │ (Subscribe)
       ↓
┌──────────────────────────────────────────────────────┐
│ MQTT Collector (pkg/iot/mqtt_collector.go)          │
│ • Listens to all sensor topics                      │
│ • Receives messages                                  │
│ • Parses JSON                                        │
└──────┬───────────────────────────────────────────────┘
       │
       │ (Send to channel)
       ↓
┌──────────────────────────────────────────────────────┐
│ dataChan (Buffered Channel, capacity: 100)          │
│ • Queue for sensor readings                          │
│ • Decouples collection from processing              │
└──────┬───────────────────────────────────────────────┘
       │
       │ (Read from channel)
       ↓
┌──────────────────────────────────────────────────────┐
│ processIncomingData() (cmd/server/main.go)          │
│ • Validates data                                     │
│ • Checks thresholds                                  │
│ • Generates alerts                                   │
│ • Stores to database (future)                       │
└──────────────────────────────────────────────────────┘
```

### **Example: Sensor Message Flow**

**1. Sensor publishes data:**
```json
Topic: sensors/soil/field_001/data

Payload: {
  "id": "reading_12345",
  "device_id": "soil_sensor_001",
  "timestamp": "2025-10-06T10:30:00Z",
  "location": {
    "field_id": "field_001",
    "crop_type": "potato"
  },
  "measurements": {
    "soil_moisture": {
      "value": 35.5,
      "unit": "%"
    },
    "soil_temperature": {
      "value": 22.3,
      "unit": "°C"
    }
  }
}
```

**2. MQTT Collector receives it:**
```go
func (m *MQTTCollector) messageHandler(client mqtt.Client, msg mqtt.Message) {
    var reading models.SensorReading
    json.Unmarshal(msg.Payload(), &reading)
    
    // Send to channel (non-blocking)
    select {
    case m.dataChan <- reading:
        log.Printf("Received data from %s", reading.DeviceID)
    default:
        log.Printf("Channel full, dropping message")
    }
}
```

**3. Processor handles it:**
```go
func processIncomingData(dataChan chan models.SensorReading) {
    for data := range dataChan {
        // Check for alerts
        if soilMoisture < 20.0 {
            log.Printf("⚠️ ALERT: Low moisture at field %s", data.Location.FieldID)
        }
        
        // Store to database (future)
        // storeToInfluxDB(data)
    }
}
```

---

## 3. 🧠 RAG System Workflow

### **How RAG (Retrieval-Augmented Generation) Works**

RAG = **Retrieval** (find relevant info) + **Augmented** (enhance) + **Generation** (LLM creates answer)

```
┌─────────────────────────────────────────────────────────────────┐
│ STEP-BY-STEP: User asks "Should I irrigate my potato field?"   │
└─────────────────────────────────────────────────────────────────┘

STEP 1: Query Enhancement
┌──────────────────────────────────────────────────────────────┐
│ User Query: "Should I irrigate?"                             │
│      ↓                                                        │
│ Add Sensor Context:                                          │
│ "Field context: field_001, Soil moisture: 35.5%,            │
│  Soil temperature: 22.3°C, Crop: potato                     │
│  Question: Should I irrigate?"                               │
└──────────────────────────────────────────────────────────────┘

STEP 2: Convert Query to Vector
┌──────────────────────────────────────────────────────────────┐
│ Embedding Service (pkg/rag/embeddings.go)                   │
│                                                              │
│ Text: "Field context: field_001, Soil moisture: 35.5%..."   │
│      ↓ (Ollama API call)                                     │
│ Vector: [0.234, -0.567, 0.123, ..., 0.891]                  │
│         (768 dimensional array)                              │
└──────────────────────────────────────────────────────────────┘

STEP 3: Search Vector Database
┌──────────────────────────────────────────────────────────────┐
│ Vector Store (pkg/rag/vector_store.go)                      │
│                                                              │
│ Query Vector → Qdrant → Find Similar Vectors                │
│                                                              │
│ Returns Top 5 Most Similar Documents:                       │
│ 1. "Potatoes require 60-80% soil moisture..." (Score: 0.89) │
│ 2. "Water stress during tuber formation..." (Score: 0.85)   │
│ 3. "Drip irrigation is most efficient..." (Score: 0.82)     │
└──────────────────────────────────────────────────────────────┘

STEP 4: Build Context for LLM
┌──────────────────────────────────────────────────────────────┐
│ Decision Handler (internal/handlers/decision.go)            │
│                                                              │
│ Prompt = "You are an agricultural expert.                   │
│           Based on the following knowledge:                  │
│                                                              │
│           Document 1: Potatoes require 60-80% moisture...    │
│           Document 2: Water stress during tuber formation... │
│           Document 3: Drip irrigation is most efficient...   │
│                                                              │
│           Current sensors: 35.5% moisture, 22.3°C            │
│                                                              │
│           Question: Should I irrigate?                       │
│                                                              │
│           Provide practical recommendations."                │
└──────────────────────────────────────────────────────────────┘

STEP 5: LLM Generates Response
┌──────────────────────────────────────────────────────────────┐
│ LLM Client (pkg/llm/ollama.go)                              │
│                                                              │
│ → Send to Ollama (llama3.2)                                 │
│ → LLM processes context + question                          │
│ → Generates intelligent answer                              │
│                                                              │
│ Response: "Based on your current soil moisture of 35.5%,    │
│            which is below the optimal 60-80% range for      │
│            potatoes, irrigation is strongly recommended.     │
│            The soil temperature of 22.3°C is ideal, but     │
│            adequate moisture is crucial during tuber         │
│            formation. Consider drip irrigation for          │
│            efficiency..."                                    │
└──────────────────────────────────────────────────────────────┘

STEP 6: Parse & Structure Response
┌──────────────────────────────────────────────────────────────┐
│ Extract Action Items:                                        │
│ • Check for keywords: "irrigate", "water" → irrigation       │
│ • Check for keywords: "fertilize" → fertilization           │
│                                                              │
│ Build JSON Response:                                        │
│ {                                                            │
│   "recommendation": "Based on your current...",              │
│   "confidence": 0.85,                                        │
│   "sources": ["Doc 1...", "Doc 2...", "Doc 3..."],         │
│   "actions": ["irrigation_recommended"]                     │
│ }                                                            │
└──────────────────────────────────────────────────────────────┘

STEP 7: Return to User
┌──────────────────────────────────────────────────────────────┐
│ HTTP Response (200 OK)                                       │
│ Content-Type: application/json                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 4. 🌐 API Request Handling

### **Example: Complete API Request Flow**

**User makes a request:**
```bash
curl -X POST http://localhost:8080/api/v1/decision \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Should I irrigate my potato field?",
    "field_id": "field_001"
  }'
```

**What happens:**

```
1. Request arrives at port 8080
   ↓
2. Gin Router matches route: POST /api/v1/decision
   ↓
3. Calls: decisionHandler.GetDecision(ctx)
   File: internal/handlers/decision.go
   ↓
4. Handler parses JSON request body
   ↓
5. Calls: knowledgeService.SearchKnowledge(query, sensorData)
   File: internal/services/knowledge.go
   ↓
6. Knowledge service:
   a) Enhances query with context
   b) Gets embedding for query
   c) Searches vector store
   d) Returns relevant documents
   ↓
7. Handler builds LLM prompt with documents
   ↓
8. Calls: llmClient.Chat(messages, tools)
   File: pkg/llm/ollama.go
   ↓
9. LLM generates recommendation
   ↓
10. Handler parses response for actions
    ↓
11. Builds JSON response
    ↓
12. Returns HTTP 200 with JSON
```

---

## 5. 📁 File-by-File Explanation

### **Directory: `cmd/` (Application Entry Points)**

#### **`cmd/server/main.go`** (179 lines)
**Purpose:** Main server application

**What it does:**
- Initializes all services (vector store, LLM, MQTT)
- Sets up HTTP routes
- Starts background workers
- Handles graceful shutdown

**Key functions:**
- `main()` - Entry point
- `processIncomingData()` - Processes sensor data

**When executed:** When you run `./bin/server`

---

#### **`cmd/cli/main.go`** (160 lines)
**Purpose:** Command-line administration tool

**What it does:**
- Adds knowledge to vector database
- Searches knowledge base
- Tests embedding generation

**Commands:**
```bash
./bin/cli add-knowledge      # Populate knowledge
./bin/cli search "query"     # Search knowledge
./bin/cli test-embedding     # Test embeddings
```

---

### **Directory: `internal/` (Private Application Code)**

#### **`internal/config/config.go`** (45 lines)
**Purpose:** Configuration management

**What it does:**
- Loads environment variables
- Provides default values
- Returns Config struct

**Example:**
```go
cfg := config.Load()
fmt.Println(cfg.Port)  // "8080"
```

---

#### **`internal/models/sensor.go`** (35 lines)
**Purpose:** Data structures

**What it does:**
- Defines sensor data format
- Location, measurements, device status

**Example:**
```go
type SensorReading struct {
    ID           string
    DeviceID     string
    Timestamp    time.Time
    Location     Location
    Measurements map[string]Measurement
}
```

---

#### **`internal/handlers/decision.go`** (90 lines)
**Purpose:** AI decision API handler

**What it does:**
- Receives decision requests
- Searches knowledge base
- Calls LLM for recommendations
- Returns structured response

**Flow:**
```
Request → SearchKnowledge → Build Prompt → LLM → Parse → Response
```

---

#### **`internal/handlers/sensor.go`** (95 lines)
**Purpose:** Sensor data API handlers

**What it does:**
- GET /sensors/:field_id - Returns sensor data
- POST /sensors/data - Receives sensor data
- GET /fields/stats - Returns statistics

---

#### **`internal/services/knowledge.go`** (75 lines)
**Purpose:** RAG knowledge service

**What it does:**
- Enhances queries with sensor context
- Gets embeddings
- Searches vector database
- Adds new knowledge

**Key methods:**
- `SearchKnowledge()` - RAG search
- `AddKnowledge()` - Add documents
- `enhanceQueryWithSensorData()` - Context enrichment

---

#### **`internal/storage/db.go`** (60 lines)
**Purpose:** Database connection

**What it does:**
- PostgreSQL connection pooling
- Schema initialization
- Tables for fields, devices, alerts

---

#### **`internal/metrics/metrics.go`** (45 lines)
**Purpose:** Prometheus metrics

**What it does:**
- Defines metrics (counters, histograms)
- Tracks API requests
- Measures query duration

**Metrics:**
- `sensor_data_received_total`
- `rag_query_duration_seconds`
- `api_requests_total`

---

### **Directory: `pkg/` (Public Reusable Packages)**

#### **`pkg/iot/mqtt_collector.go`** (90 lines)
**Purpose:** MQTT sensor data collection

**What it does:**
- Connects to MQTT broker
- Subscribes to sensor topics
- Parses incoming messages
- Sends to data channel

**Flow:**
```
MQTT Broker → Subscribe → Receive → Parse JSON → Channel
```

---

#### **`pkg/rag/vector_store.go`** (120 lines)
**Purpose:** Qdrant vector database client

**What it does:**
- Connects to Qdrant
- Creates collections
- Adds documents with embeddings
- Searches by similarity

**Key methods:**
- `NewVectorStore()` - Initialize
- `AddDocument()` - Store embedding
- `Search()` - Find similar vectors

---

#### **`pkg/rag/embeddings.go`** (75 lines)
**Purpose:** Text embedding service

**What it does:**
- Converts text to vectors
- Uses Ollama API
- Supports batch processing

**Example:**
```go
embedding, err := es.GetEmbedding(ctx, "potato irrigation")
// Returns: []float32{0.234, -0.567, ...} (768 dimensions)
```

---

#### **`pkg/llm/ollama.go`** (95 lines)
**Purpose:** LLM client for Ollama

**What it does:**
- Sends chat requests to Ollama
- Supports tool calling
- Generates text completions

**Example:**
```go
messages := []Message{
    {Role: "system", Content: "You are an expert..."},
    {Role: "user", Content: "Should I irrigate?"},
}
response, err := client.Chat(ctx, messages, nil)
```

---

#### **`pkg/cache/redis.go`** (60 lines)
**Purpose:** Redis caching layer

**What it does:**
- Caches knowledge search results
- Caches sensor data
- Improves performance

---

### **Directory: `test/`**

#### **`test/integration_test.go`** (100 lines)
**Purpose:** Integration tests

**What it does:**
- Tests HTTP endpoints
- Validates responses
- Ensures API works correctly

---

### **Directory: `scripts/`**

#### **`scripts/setup.sh`**
**Purpose:** Project setup automation

**What it does:**
- Checks prerequisites
- Downloads dependencies
- Builds binaries
- Creates .env file

---

#### **`scripts/simulate_sensors.py`**
**Purpose:** Sensor data simulator

**What it does:**
- Generates realistic sensor data
- Publishes to MQTT broker
- Simulates multiple fields

---

#### **`scripts/test_api.sh`**
**Purpose:** API testing

**What it does:**
- Tests all endpoints
- Validates responses
- Checks system health

---

#### **`scripts/first_run.sh`**
**Purpose:** Interactive first-time setup

**What it does:**
- Guides through setup process
- Starts services
- Tests everything

---

### **Directory: `deployments/`**

#### **`docker-compose.yml`**
**Purpose:** Service orchestration

**What it does:**
- Defines 8 services
- Configures networking
- Sets up volumes
- Links services together

**Services:**
- Qdrant (vector DB)
- Ollama (LLM)
- Mosquitto (MQTT)
- PostgreSQL (database)
- Redis (cache)
- InfluxDB (time-series)
- Prometheus (metrics)
- Grafana (dashboards)

---

#### **`Dockerfile`**
**Purpose:** Application containerization

**What it does:**
- Multi-stage build
- Compiles Go application
- Creates minimal image
- Exposes port 8080

---

## 6. 🌾 Real-World Scenario

### **Complete Example: Farmer's Day**

**Morning - 7:00 AM**

**1. Farmer checks field conditions:**
```bash
curl http://localhost:8080/api/v1/sensors/field_001
```

**Response:**
```json
{
  "device_id": "soil_sensor_001",
  "measurements": {
    "soil_moisture": {"value": 35.5, "unit": "%"},
    "soil_temperature": {"value": 18.2, "unit": "°C"}
  }
}
```

**System flow:**
```
Browser/App → API Server → Sensor Handler → Return Mock/Real Data
```

---

**2. Farmer asks for advice:**
```bash
curl -X POST http://localhost:8080/api/v1/decision \
  -d '{"query": "Should I irrigate?", "field_id": "field_001"}'
```

**System flow:**
```
1. Request → Decision Handler
2. Handler → Knowledge Service (SearchKnowledge)
3. Knowledge Service:
   a) Enhance query: "Field field_001, moisture 35.5%, temp 18.2°C, Should I irrigate?"
   b) Get embedding → [0.23, -0.56, ...]
   c) Search Qdrant → Find similar docs
   d) Return: ["Potatoes need 60-80% moisture", "Irrigation timing guide"]
4. Handler → Build LLM prompt with documents
5. Handler → LLM Client (Ollama)
6. Ollama → Generate recommendation
7. Handler → Parse actions
8. Handler → Return JSON response
```

**Response:**
```json
{
  "recommendation": "Immediate irrigation recommended. Your soil moisture of 35.5% is below the optimal 60-80% range for potatoes...",
  "confidence": 0.87,
  "sources": ["Doc about potato moisture", "Irrigation timing"],
  "actions": ["irrigation_recommended"]
}
```

---

**Throughout the day - Continuous monitoring:**

**Background processes running:**

**Process 1: MQTT Collector**
```
Every minute:
1. Sensor publishes data → sensors/soil/field_001/data
2. MQTT Collector receives
3. Parses JSON
4. Sends to dataChan
```

**Process 2: Data Processor**
```
Continuously:
1. Reads from dataChan
2. Checks thresholds
3. If moisture < 20%: Generate alert
4. If temp > 30°C: Generate alert
5. Log events
```

**Example alert:**
```
⚠️ ALERT: Low soil moisture at field field_003: 18.5%
```

---

**Evening - System monitoring:**

**Admin checks metrics:**
```bash
curl http://localhost:8080/metrics
```

**Prometheus scrapes metrics:**
```
sensor_data_received_total{field_id="field_001"} 144
rag_query_duration_seconds{quantile="0.95"} 0.234
api_requests_total{endpoint="/decision",status="200"} 12
```

**View in Grafana:**
- Dashboard shows sensor trends
- API performance graphs
- Alert history

---

## 7. 🔄 Data Flow Summary

### **The Complete Circle**

```
┌─────────────────────────────────────────────────────────────────┐
│                        Physical World                            │
│  🌾 Potato Field → 🌡️ Soil Sensor → 📡 IoT Device              │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ MQTT Message
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Digital Infrastructure                        │
│  🐳 Mosquitto (MQTT Broker)                                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Subscribe
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Our Application                               │
│  📦 MQTT Collector → 📊 Data Processor → ⚠️ Alerts              │
│  🧠 RAG System ← 📚 Knowledge Base (Qdrant)                     │
│  🤖 LLM (Ollama) → 💡 Recommendations                           │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTP API
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                         End Users                                │
│  👨‍🌾 Farmer's App/Dashboard → Make Decisions                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 8. 🎯 Key Takeaways

### **What Makes This System Smart?**

1. **Real-time Processing**
   - Goroutines handle concurrent operations
   - Channels decouple components
   - Non-blocking architecture

2. **Intelligent Recommendations**
   - RAG combines knowledge retrieval + AI
   - Context-aware responses
   - Semantic search (meaning, not keywords)

3. **Scalable Design**
   - Microservices architecture
   - Stateless API
   - Cacheable results

4. **Production Ready**
   - Error handling everywhere
   - Graceful shutdown
   - Monitoring and metrics
   - Health checks

5. **Domain-Specific**
   - Agricultural knowledge base
   - Sensor data models
   - Farm-specific recommendations

---

## 9. 💡 Quick Reference

### **When You Run...**

**`make docker-up`**
→ Starts all infrastructure (Qdrant, MQTT, databases)

**`make build`**
→ Compiles Go code into executables (bin/server, bin/cli)

**`./bin/cli add-knowledge`**
→ Adds agricultural knowledge to vector database

**`./bin/server`**
→ Starts HTTP server + MQTT collector + background workers

**`curl http://localhost:8080/api/v1/decision`**
→ Triggers: Request → Handler → RAG Search → LLM → Response

**`python3 scripts/simulate_sensors.py`**
→ Publishes fake sensor data to MQTT

---

## 10. 🎓 Summary

**Our system is like a smart agricultural assistant that:**

1. **Listens** to sensors (MQTT)
2. **Stores** agricultural knowledge (Qdrant)
3. **Understands** questions (Embeddings)
4. **Finds** relevant information (Vector search)
5. **Generates** recommendations (LLM)
6. **Monitors** everything (Prometheus)
7. **Alerts** when needed (Data processor)

**All working together to help farmers make better decisions!** 🌾

---

*Now you understand every piece of the system and how they work together!* 🎉
