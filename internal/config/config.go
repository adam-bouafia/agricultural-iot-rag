// internal/config/config.go
package config

import (
	"os"
)

type Config struct {
	Port             string
	QdrantURL        string
	OllamaURL        string
	MQTTBroker       string
	EmbeddingAPIURL  string
	EmbeddingModel   string
	LLMModel         string
	PostgresDSN      string
	InfluxDBURL      string
	InfluxDBToken    string
	InfluxDBOrg      string
	InfluxDBBucket   string
	RedisURL         string
}

func Load() *Config {
	return &Config{
		Port:            getEnv("PORT", "8080"),
		QdrantURL:       getEnv("QDRANT_URL", "localhost:6333"),
		OllamaURL:       getEnv("OLLAMA_URL", "http://localhost:11434"),
		MQTTBroker:      getEnv("MQTT_BROKER", "tcp://localhost:1883"),
		EmbeddingAPIURL: getEnv("EMBEDDING_API_URL", "http://localhost:11434"),
		EmbeddingModel:  getEnv("EMBEDDING_MODEL", "nomic-embed-text"),
		LLMModel:        getEnv("LLM_MODEL", "llama3.2"),
		PostgresDSN:     getEnv("POSTGRES_DSN", "host=localhost user=postgres password=password dbname=agricultural_iot port=5432 sslmode=disable"),
		InfluxDBURL:     getEnv("INFLUXDB_URL", "http://localhost:8086"),
		InfluxDBToken:   getEnv("INFLUXDB_TOKEN", "my-token"),
		InfluxDBOrg:     getEnv("INFLUXDB_ORG", "agurotech"),
		InfluxDBBucket:  getEnv("INFLUXDB_BUCKET", "sensors"),
		RedisURL:        getEnv("REDIS_URL", "localhost:6379"),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
