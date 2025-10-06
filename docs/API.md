# Agricultural IoT RAG System - API Documentation

## Base URL
```
http://localhost:8080/api/v1
```

## Endpoints

### 1. Health Check

**GET** `/health`

Check if the server is running.

**Response:**
```json
{
  "status": "ok",
  "timestamp": 1696579200,
  "service": "agricultural-iot-rag"
}
```

---

### 2. Get Decision Support

**POST** `/api/v1/decision`

Get AI-powered agricultural recommendations based on RAG.

**Request Body:**
```json
{
  "query": "Should I irrigate my potato field?",
  "field_id": "field_001",
  "sensor_data": {
    "soil_moisture": 35.5,
    "soil_temperature": 22.0
  }
}
```

**Response:**
```json
{
  "recommendation": "Based on current soil moisture of 35.5%, irrigation is recommended...",
  "confidence": 0.85,
  "sources": [
    "Potatoes require consistent soil moisture levels between 60-80%...",
    "Water stress during tuber formation can significantly reduce yield..."
  ],
  "actions": ["irrigation_recommended"]
}
```

---

### 3. Get Sensor Data

**GET** `/api/v1/sensors/:field_id`

Get current sensor readings for a specific field.

**Parameters:**
- `field_id` (path): Field identifier

**Response:**
```json
{
  "id": "reading_001",
  "device_id": "device_field_001",
  "timestamp": "2025-10-06T10:30:00Z",
  "location": {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "field_id": "field_001",
    "crop_type": "potato"
  },
  "measurements": {
    "soil_moisture": {
      "value": 45.5,
      "unit": "%",
      "quality": "good"
    },
    "soil_temperature": {
      "value": 22.3,
      "unit": "°C",
      "quality": "good"
    }
  },
  "device_status": {
    "battery_level": 85,
    "signal_strength": -65,
    "last_calibration": "2025-10-05T10:30:00Z"
  }
}
```

---

### 4. Submit Sensor Data

**POST** `/api/v1/sensors/data`

Submit new sensor readings.

**Request Body:**
```json
{
  "id": "reading_002",
  "device_id": "sensor_001",
  "timestamp": "2025-10-06T10:30:00Z",
  "location": {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "field_id": "field_001",
    "crop_type": "potato"
  },
  "measurements": {
    "soil_moisture": {
      "value": 45.5,
      "unit": "%"
    }
  },
  "device_status": {
    "battery_level": 85,
    "signal_strength": -65,
    "last_calibration": "2025-10-05T10:30:00Z"
  }
}
```

**Response:**
```json
{
  "status": "received",
  "message": "Sensor data processed successfully",
  "id": "reading_002"
}
```

---

### 5. Get Field Statistics

**GET** `/api/v1/fields/stats`

Get aggregated statistics across all fields.

**Response:**
```json
{
  "total_fields": 10,
  "active_sensors": 25,
  "alerts": [
    "Field 3: Low soil moisture detected",
    "Field 7: High temperature alert"
  ],
  "avg_soil_moisture": 48.5,
  "avg_temperature": 23.2
}
```

---

### 6. Prometheus Metrics

**GET** `/metrics`

Get Prometheus metrics for monitoring.

---

## MQTT Topics

### Subscribe to Sensor Data

**Topics:**
- `sensors/soil/+/data` - Soil sensor readings
- `sensors/weather/+/data` - Weather sensor readings
- `sensors/crop/+/data` - Crop monitoring data

**Message Format:**
```json
{
  "id": "reading_001",
  "device_id": "soil_sensor_001",
  "timestamp": "2025-10-06T10:30:00Z",
  "location": {
    "field_id": "field_001"
  },
  "measurements": {
    "soil_moisture": {
      "value": 45.5,
      "unit": "%"
    }
  }
}
```

---

## CLI Commands

### Add Knowledge

```bash
./bin/cli add-knowledge
```

Populates the vector store with agricultural knowledge.

### Search Knowledge

```bash
./bin/cli search "How to irrigate potato fields?"
```

Search the knowledge base and return relevant documents.

### Test Embeddings

```bash
./bin/cli test-embedding
```

Test the embedding generation service.

---

## Examples

### cURL Examples

**Health Check:**
```bash
curl http://localhost:8080/health
```

**Get Sensor Data:**
```bash
curl http://localhost:8080/api/v1/sensors/field_001
```

**Submit Sensor Data:**
```bash
curl -X POST http://localhost:8080/api/v1/sensors/data \
  -H "Content-Type: application/json" \
  -d '{
    "id": "test_001",
    "device_id": "sensor_001",
    "location": {"field_id": "field_001"},
    "measurements": {
      "soil_moisture": {"value": 45.5, "unit": "%"}
    },
    "device_status": {
      "battery_level": 85,
      "signal_strength": -65
    }
  }'
```

**Get Decision:**
```bash
curl -X POST http://localhost:8080/api/v1/decision \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Should I irrigate my potato field?",
    "field_id": "field_001"
  }'
```

---

## Error Responses

All error responses follow this format:

```json
{
  "error": "Error message describing what went wrong"
}
```

Common HTTP status codes:
- `200` - Success
- `400` - Bad Request (invalid input)
- `404` - Not Found
- `500` - Internal Server Error
