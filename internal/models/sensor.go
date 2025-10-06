// internal/models/sensor.go
package models

import (
	"time"
)

type SensorReading struct {
	ID           string                 `json:"id"`
	DeviceID     string                 `json:"device_id"`
	Timestamp    time.Time              `json:"timestamp"`
	Location     Location               `json:"location"`
	Measurements map[string]Measurement `json:"measurements"`
	DeviceStatus DeviceStatus           `json:"device_status"`
}

type Location struct {
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	FieldID   string  `json:"field_id"`
	CropType  string  `json:"crop_type,omitempty"`
}

type Measurement struct {
	Value   interface{} `json:"value"`
	Unit    string      `json:"unit"`
	Quality string      `json:"quality,omitempty"`
}

type DeviceStatus struct {
	BatteryLevel    int       `json:"battery_level"`
	SignalStrength  int       `json:"signal_strength"`
	LastCalibration time.Time `json:"last_calibration"`
}
