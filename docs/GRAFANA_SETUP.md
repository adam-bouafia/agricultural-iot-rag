# Grafana Dashboard Setup Guide

## 🎯 Overview

This guide will help you set up **4 comprehensive dashboards** to monitor your Agricultural IoT RAG System.

## 📊 Dashboard Collection

### 1. **Main Overview Dashboard** 🏠
**File:** `deployments/grafana-dashboards/main-overview.json`

**What it shows:**
- ✅ Total AI Decision Requests (stat card)
- ✅ Sensor Readings Received (stat card)
- ✅ MQTT Messages Received (stat card)
- ✅ System Health Status (UP/DOWN)
- 📈 AI Decision Request Rate over time
- 📈 Sensor Data Ingestion Rate by field
- ⏱️ Average Decision Response Time (gauge)
- 🔄 HTTP Requests by Endpoint
- 🥧 HTTP Status Code Distribution (pie chart)
- 🌡️ Decision Request Duration Heatmap

**Best for:** Quick system health check and overall performance monitoring

---

### 2. **Sensor Monitoring Dashboard** 📡
**File:** `deployments/grafana-dashboards/sensor-monitoring.json`

**What it shows:**
- 📊 Total Sensor Readings by Field (multi-stat)
- 📈 Sensor Reading Rate per field/device over time
- 📨 MQTT Messages Received Over Time
- 📊 Sensor Data Points Received
- 📋 Active Sensors Table (which sensors are reporting)
- 📊 Sensor Reading Frequency by Device (bar gauge)

**Best for:** IoT sensor health monitoring, identifying inactive sensors, tracking data ingestion

---

### 3. **AI Performance & Analytics Dashboard** 🤖
**File:** `deployments/grafana-dashboards/ai-performance.json`

**What it shows:**
- 📊 AI Decision Requests Overview (total)
- 📊 Decisions Made in Last Hour
- ⏱️ Average Response Time (5m window)
- 📊 Current Requests/min
- 📈 AI Decision Request Rate (5m vs 1m comparison)
- 📊 Response Time Distribution (50th, 90th, 95th, 99th percentiles)
- ⏱️ Response Time Gauge (with thresholds)
- 🌡️ Request Volume Heatmap (hourly patterns)
- 📈 Cumulative Decision Requests (growth over time)
- ✅ Decision Request Success Rate (%)

**Best for:** AI/LLM performance analysis, identifying slow queries, capacity planning

---

### 4. **System Health & Infrastructure Dashboard** 🏗️
**File:** `deployments/grafana-dashboards/system-health.json`

**What it shows:**
- ⏰ System Uptime
- 📊 Total HTTP Requests
- 📊 HTTP Request Rate
- ⚠️ Error Rate (4xx/5xx)
- 📈 HTTP Requests by Endpoint (stacked graph)
- 📊 HTTP Status Code Distribution (2xx/4xx/5xx)
- 📋 API Endpoint Performance Table (ranked by traffic)
- 📊 Top 10 Endpoints by Traffic (bar gauge)
- 📈 Request Volume Trend (24h)
- 🔧 Go Runtime Metrics (goroutines, threads)
- 💾 Go Memory Usage (allocated, system, heap)

**Best for:** Infrastructure monitoring, troubleshooting errors, resource usage tracking

---

## 🚀 Quick Setup Instructions

### Step 1: Add Prometheus Data Source (if not done)

1. Open Grafana: http://localhost:3000
2. Login (default: admin/admin)
3. Go to **Configuration** (⚙️) → **Data Sources**
4. Click **Add data source**
5. Select **Prometheus**
6. Set URL: `http://prometheus:9090`
7. Click **Save & Test** (should see ✅ "Data source is working")

### Step 2: Import Dashboards

**For each dashboard file:**

1. Go to **Dashboards** (📊) → **Import**
2. Click **Upload JSON file**
3. Select the dashboard file:
   - `main-overview.json`
   - `sensor-monitoring.json`
   - `ai-performance.json`
   - `system-health.json`
4. Select **Prometheus** as the data source
5. Click **Import**

**Or use the file path method:**
```bash
# Copy the JSON content from each file in:
deployments/grafana-dashboards/

# In Grafana Import:
# - Paste JSON directly
# - Select Prometheus data source
# - Click Import
```

---

## 📋 Available Prometheus Metrics

### Core Application Metrics (from `internal/metrics/metrics.go`):

```promql
# Decision/AI Metrics
decision_requests_total                    # Counter: Total AI decision requests
decision_request_duration_seconds          # Histogram: Response time distribution
decision_request_duration_seconds_bucket   # Buckets: 0.1s, 0.5s, 1s, 2s, 5s, 10s
decision_request_duration_seconds_sum      # Sum of all durations
decision_request_duration_seconds_count    # Count of requests

# Sensor Metrics
sensor_readings_total{field_id,device_id}  # Counter: Sensor readings by field/device
sensor_data_received_total                 # Counter: Total data points received

# MQTT Metrics
mqtt_messages_received_total               # Counter: MQTT messages received

# HTTP Metrics
http_requests_total{method,path,status}    # Counter: HTTP requests by endpoint/status
```

### Go Runtime Metrics (built-in):

```promql
# Process
process_start_time_seconds    # Process start time (for uptime)
up                           # Service health (1=up, 0=down)

# Goroutines/Threads
go_goroutines                # Number of goroutines
go_threads                   # Number of OS threads

# Memory
go_memstats_alloc_bytes      # Bytes allocated and in use
go_memstats_sys_bytes        # Bytes obtained from system
go_memstats_heap_inuse_bytes # Heap bytes in use
go_memstats_heap_alloc_bytes # Heap bytes allocated
go_memstats_heap_idle_bytes  # Heap bytes idle
go_memstats_gc_sys_bytes     # GC metadata bytes

# GC Stats
go_gc_duration_seconds       # GC duration
go_memstats_gc_cpu_fraction  # GC CPU fraction
```

---

## 🔍 Example PromQL Queries

### Calculate request rate:
```promql
rate(decision_requests_total[5m]) * 60  # Requests per minute
```

### Calculate average response time:
```promql
rate(decision_request_duration_seconds_sum[5m]) / 
rate(decision_request_duration_seconds_count[5m])
```

### Calculate 95th percentile latency:
```promql
histogram_quantile(0.95, rate(decision_request_duration_seconds_bucket[5m]))
```

### Count active sensors (reporting in last 5m):
```promql
count(rate(sensor_readings_total[5m]) > 0)
```

### Calculate error rate:
```promql
sum(rate(http_requests_total{status=~"4..|5.."}[5m])) / 
sum(rate(http_requests_total[5m])) * 100
```

### Calculate uptime:
```promql
time() - process_start_time_seconds
```

### Top 10 endpoints by traffic:
```promql
topk(10, sum(rate(http_requests_total[5m])) by (path))
```

---

## 🎨 Dashboard Customization Tips

### 1. **Adjust Time Ranges**
- Click time picker (top-right)
- Common ranges: Last 5m, 15m, 1h, 6h, 24h
- Set auto-refresh: 5s, 10s, 30s, 1m

### 2. **Customize Thresholds**
Edit panel → Field → Thresholds:
- Response time: 0s=green, 2s=yellow, 5s=red
- Error rate: 0%=green, 1%=yellow, 5%=red

### 3. **Add Alerts** (Grafana Alerting)
- Edit panel → Alert tab
- Set conditions (e.g., response time > 5s)
- Configure notifications (email, Slack, webhook)

### 4. **Create Variables**
Dashboard settings → Variables → Add variable:
- `$field_id` - Filter by field
- `$device_id` - Filter by device
- `$time_range` - Dynamic time range

Example query with variable:
```promql
sensor_readings_total{field_id="$field_id"}
```

---

## 📈 What Each Dashboard Answers

### Main Overview
- ❓ "Is my system healthy?"
- ❓ "How many decisions are being made?"
- ❓ "Are sensors sending data?"
- ❓ "What's the response time?"

### Sensor Monitoring
- ❓ "Which sensors are active?"
- ❓ "Is sensor data arriving consistently?"
- ❓ "Which fields are producing the most data?"
- ❓ "Are there any inactive sensors?"

### AI Performance
- ❓ "How fast are AI decisions?"
- ❓ "What's the 95th percentile latency?"
- ❓ "When is peak usage?"
- ❓ "Is performance degrading over time?"
- ❓ "What's the success rate?"

### System Health
- ❓ "How long has the system been running?"
- ❓ "What's the error rate?"
- ❓ "Which endpoints get the most traffic?"
- ❓ "Is memory usage stable?"
- ❓ "Are there any resource leaks?"

---

## 🚨 Alert Recommendations

### Critical Alerts:
```yaml
- System Down (up == 0)
- Error Rate > 5%
- AI Response Time > 10s
- No Sensor Data for 10m
```

### Warning Alerts:
```yaml
- Response Time > 5s
- Error Rate > 1%
- Memory Usage > 80%
- No MQTT Messages for 5m
```

---

## 🔧 Troubleshooting

### "No Data" in Panels

1. **Check Prometheus is scraping:**
   ```bash
   curl http://localhost:9090/api/v1/targets
   ```

2. **Check metrics are exposed:**
   ```bash
   curl http://localhost:8081/metrics
   ```

3. **Verify time range** (adjust to wider range)

4. **Check PromQL syntax** in panel query

### "Data source is not working"

1. **Check Prometheus URL:**
   - Use `http://prometheus:9090` (Docker network)
   - NOT `http://localhost:9090` (from Grafana container)

2. **Check Prometheus is running:**
   ```bash
   docker compose ps prometheus
   ```

### Panels Show Old Data

1. **Increase refresh rate** (top-right dropdown)
2. **Adjust time range** to "Last 5 minutes"
3. **Check if server is running** and generating metrics

---

## 🎯 Next Steps

1. ✅ Import all 4 dashboards
2. ✅ Generate some traffic:
   ```bash
   # Test AI endpoint
   curl -X POST http://localhost:8081/api/v1/decision \
     -H "Content-Type: application/json" \
     -d '{
       "query": "Should I irrigate?",
       "field_id": "field_001",
       "sensor_data": {"soil_moisture": 35.5}
     }'
   ```
3. ✅ Watch metrics populate in dashboards
4. ✅ Customize thresholds and colors
5. ✅ Set up alerts for critical metrics
6. ✅ Create custom dashboards for specific use cases

---

## 📚 Additional Resources

- **Prometheus Query Basics:** https://prometheus.io/docs/prometheus/latest/querying/basics/
- **Grafana Dashboard Best Practices:** https://grafana.com/docs/grafana/latest/best-practices/
- **PromQL Functions:** https://prometheus.io/docs/prometheus/latest/querying/functions/

---

**Happy Monitoring! 📊🚀**
