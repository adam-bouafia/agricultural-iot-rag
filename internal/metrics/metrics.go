// internal/metrics/metrics.go
package metrics

import (
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
)

var (
	SensorDataReceived = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "sensor_data_received_total",
			Help: "Total number of sensor data points received",
		},
		[]string{"device_type", "field_id"},
	)

	RAGQueryDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "rag_query_duration_seconds",
			Help:    "Time spent processing RAG queries",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"query_type"},
	)

	LLMRequestDuration = promauto.NewHistogram(
		prometheus.HistogramOpts{
			Name:    "llm_request_duration_seconds",
			Help:    "Time spent on LLM requests",
			Buckets: prometheus.DefBuckets,
		},
	)

	VectorSearchDuration = promauto.NewHistogram(
		prometheus.HistogramOpts{
			Name:    "vector_search_duration_seconds",
			Help:    "Time spent on vector database searches",
			Buckets: prometheus.DefBuckets,
		},
	)

	APIRequestsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "api_requests_total",
			Help: "Total number of API requests",
		},
		[]string{"method", "endpoint", "status"},
	)

	ActiveConnections = promauto.NewGauge(
		prometheus.GaugeOpts{
			Name: "active_mqtt_connections",
			Help: "Number of active MQTT connections",
		},
	)
)
