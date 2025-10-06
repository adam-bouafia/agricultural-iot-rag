#!/bin/bash

# Test script for Agricultural IoT RAG System

API_URL="http://localhost:8080"

echo "🧪 Testing Agricultural IoT RAG System"
echo "====================================="

# Test 1: Health check
echo ""
echo "Test 1: Health Check"
response=$(curl -s "${API_URL}/health")
if [ $? -eq 0 ]; then
    echo "✓ Health check passed"
    echo "Response: $response"
else
    echo "❌ Health check failed"
    exit 1
fi

# Test 2: Get sensor data
echo ""
echo "Test 2: Get Sensor Data"
response=$(curl -s "${API_URL}/api/v1/sensors/field_001")
if [ $? -eq 0 ]; then
    echo "✓ Get sensor data passed"
    echo "Response: $response" | jq '.' 2>/dev/null || echo "$response"
else
    echo "❌ Get sensor data failed"
fi

# Test 3: Post sensor data
echo ""
echo "Test 3: Post Sensor Data"
payload='{
  "id": "test_001",
  "device_id": "device_test",
  "timestamp": "2025-10-06T10:00:00Z",
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
    "last_calibration": "2025-10-05T10:00:00Z"
  }
}'

response=$(curl -s -X POST "${API_URL}/api/v1/sensors/data" \
  -H "Content-Type: application/json" \
  -d "$payload")
if [ $? -eq 0 ]; then
    echo "✓ Post sensor data passed"
    echo "Response: $response"
else
    echo "❌ Post sensor data failed"
fi

# Test 4: Get field stats
echo ""
echo "Test 4: Get Field Stats"
response=$(curl -s "${API_URL}/api/v1/fields/stats")
if [ $? -eq 0 ]; then
    echo "✓ Get field stats passed"
    echo "Response: $response" | jq '.' 2>/dev/null || echo "$response"
else
    echo "❌ Get field stats failed"
fi

# Test 5: Decision API (if available)
echo ""
echo "Test 5: Decision API"
decision_payload='{
  "query": "Should I irrigate my potato field?",
  "field_id": "field_001"
}'

response=$(curl -s -X POST "${API_URL}/api/v1/decision" \
  -H "Content-Type: application/json" \
  -d "$decision_payload")
if [ $? -eq 0 ]; then
    echo "✓ Decision API passed"
    echo "Response: $response" | jq '.' 2>/dev/null || echo "$response"
else
    echo "⚠️  Decision API may not be available (requires Ollama and Qdrant)"
fi

echo ""
echo "✅ Tests complete!"
