// internal/handlers/sensor.go
package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"

	"agricultural-iot-rag/internal/models"
)

type SensorHandler struct {
	// You can add storage/database connections here
}

func NewSensorHandler() *SensorHandler {
	return &SensorHandler{}
}

func (sh *SensorHandler) GetSensorData(c *gin.Context) {
	fieldID := c.Param("field_id")

	// Mock data for demonstration
	// In production, fetch from time-series database
	reading := models.SensorReading{
		ID:        "reading_001",
		DeviceID:  "device_" + fieldID,
		Timestamp: time.Now(),
		Location: models.Location{
			Latitude:  40.7128,
			Longitude: -74.0060,
			FieldID:   fieldID,
			CropType:  "potato",
		},
		Measurements: map[string]models.Measurement{
			"soil_moisture": {
				Value:   45.5,
				Unit:    "%",
				Quality: "good",
			},
			"soil_temperature": {
				Value:   22.3,
				Unit:    "°C",
				Quality: "good",
			},
			"air_temperature": {
				Value:   25.1,
				Unit:    "°C",
				Quality: "good",
			},
			"humidity": {
				Value:   65.0,
				Unit:    "%",
				Quality: "good",
			},
		},
		DeviceStatus: models.DeviceStatus{
			BatteryLevel:    85,
			SignalStrength:  -65,
			LastCalibration: time.Now().Add(-24 * time.Hour),
		},
	}

	c.JSON(http.StatusOK, reading)
}

func (sh *SensorHandler) ReceiveSensorData(c *gin.Context) {
	var reading models.SensorReading
	if err := c.ShouldBindJSON(&reading); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// In production, save to time-series database
	// For now, just acknowledge receipt
	c.JSON(http.StatusOK, gin.H{
		"status":  "received",
		"message": "Sensor data processed successfully",
		"id":      reading.ID,
	})
}

func (sh *SensorHandler) GetFieldsStats(c *gin.Context) {
	// Mock statistics for demonstration
	stats := gin.H{
		"total_fields": 10,
		"active_sensors": 25,
		"alerts": []string{
			"Field 3: Low soil moisture detected",
			"Field 7: High temperature alert",
		},
		"avg_soil_moisture": 48.5,
		"avg_temperature":   23.2,
	}

	c.JSON(http.StatusOK, stats)
}
