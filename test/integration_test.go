// test/integration_test.go
package test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"

	"agricultural-iot-rag/internal/handlers"
)

func setupTestRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	router := gin.Default()

	sensorHandler := handlers.NewSensorHandler()

	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	api := router.Group("/api/v1")
	{
		api.GET("/sensors/:field_id", sensorHandler.GetSensorData)
		api.POST("/sensors/data", sensorHandler.ReceiveSensorData)
		api.GET("/fields/stats", sensorHandler.GetFieldsStats)
	}

	return router
}

func TestHealthEndpoint(t *testing.T) {
	router := setupTestRouter()

	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/health", nil)
	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "ok", response["status"])
}

func TestGetSensorData(t *testing.T) {
	router := setupTestRouter()

	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/v1/sensors/field_001", nil)
	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.NotEmpty(t, response["id"])
	assert.NotEmpty(t, response["device_id"])
}

func TestReceiveSensorData(t *testing.T) {
	router := setupTestRouter()

	payload := map[string]interface{}{
		"id":        "test_001",
		"device_id": "device_test",
		"location": map[string]interface{}{
			"field_id": "field_001",
		},
		"measurements": map[string]interface{}{},
		"device_status": map[string]interface{}{
			"battery_level":   85,
			"signal_strength": -65,
		},
	}

	jsonData, _ := json.Marshal(payload)
	w := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/api/v1/sensors/data", bytes.NewBuffer(jsonData))
	req.Header.Set("Content-Type", "application/json")
	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, "received", response["status"])
}

func TestGetFieldsStats(t *testing.T) {
	router := setupTestRouter()

	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/api/v1/fields/stats", nil)
	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)

	var response map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.NotNil(t, response["total_fields"])
	assert.NotNil(t, response["active_sensors"])
}
