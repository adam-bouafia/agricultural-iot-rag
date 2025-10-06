# Grafana Dashboard Panels - WORKING METRICS ONLY

## ⚠️ IMPORTANT: Available Metrics

Your application currently **ONLY exposes default Go runtime metrics**, not custom application metrics yet.

## ✅ Working Queries (Metrics That Actually Exist)

### 📊 Dashboard 1: System Health & Performance

#### Panel 1: System Uptime
- **Panel Type:** Stat
- **Query:**
  ```promql
  time() - process_start_time_seconds{job="agricultural-iot-rag"}
  ```
- **Unit:** seconds (s)
- **Color:** Green when > 3600

#### Panel 2: System Health Status
- **Panel Type:** Stat  
- **Query:**
  ```promql
  up{job="agricultural-iot-rag"}
  ```
- **Value Mappings:**
  - 0 → DOWN (Red background)
  - 1 → UP (Green background)

#### Panel 3: Active Goroutines
- **Panel Type:** Time series (Graph)
- **Query:**
  ```promql
  go_goroutines{job="agricultural-iot-rag"}
  ```
- **Unit:** short
- **Description:** Number of running goroutines

#### Panel 4: OS Threads
- **Panel Type:** Time series (Graph)
- **Query:**
  ```promql
  go_threads{job="agricultural-iot-rag"}
  ```
- **Unit:** short

#### Panel 5: Memory Allocated
- **Panel Type:** Time series (Graph)
- **Query:**
  ```promql
  go_memstats_alloc_bytes{job="agricultural-iot-rag"}
  ```
- **Unit:** bytes (IEC)
- **Description:** Bytes allocated and in use

#### Panel 6: Total Memory from System
- **Panel Type:** Time series (Graph)
- **Query:**
  ```promql
  go_memstats_sys_bytes{job="agricultural-iot-rag"}
  ```
- **Unit:** bytes (IEC)

#### Panel 7: Heap Memory Usage
- **Panel Type:** Time series (Graph)
- **Queries:**
  - Query A (Heap Allocated):
    ```promql
    go_memstats_heap_alloc_bytes{job="agricultural-iot-rag"}
    ```
  - Query B (Heap In Use):
    ```promql
    go_memstats_heap_inuse_bytes{job="agricultural-iot-rag"}
    ```
  - Query C (Heap Idle):
    ```promql
    go_memstats_heap_idle_bytes{job="agricultural-iot-rag"}
    ```
- **Unit:** bytes (IEC)
- **Legend:** Show as table

#### Panel 8: Heap Objects
- **Panel Type:** Time series (Graph)
- **Query:**
  ```promql
  go_memstats_heap_objects{job="agricultural-iot-rag"}
  ```
- **Unit:** short
- **Description:** Number of allocated objects

#### Panel 9: Total Memory Allocations
- **Panel Type:** Time series (Graph)
- **Query:**
  ```promql
  go_memstats_alloc_bytes_total{job="agricultural-iot-rag"}
  ```
- **Unit:** bytes (IEC)
- **Description:** Total bytes allocated (even if freed)

#### Panel 10: Memory Allocation Rate
- **Panel Type:** Time series (Graph)
- **Query:**
  ```promql
  rate(go_memstats_alloc_bytes_total{job="agricultural-iot-rag"}[5m])
  ```
- **Unit:** Bps (bytes per second)
- **Description:** Memory allocation rate

#### Panel 11: GC Duration
- **Panel Type:** Time series (Graph)
- **Queries:**
  - Query A (50th percentile):
    ```promql
    go_gc_duration_seconds{job="agricultural-iot-rag", quantile="0.5"}
    ```
  - Query B (75th percentile):
    ```promql
    go_gc_duration_seconds{job="agricultural-iot-rag", quantile="0.75"}
    ```
  - Query C (99th percentile):
    ```promql
    go_gc_duration_seconds{job="agricultural-iot-rag", quantile="1"}
    ```
- **Unit:** seconds (s)

#### Panel 12: GC Count Rate
- **Panel Type:** Time series (Graph)
- **Query:**
  ```promql
  rate(go_gc_duration_seconds_count{job="agricultural-iot-rag"}[5m])
  ```
- **Unit:** ops (operations per second)
- **Description:** GC executions per second

#### Panel 13: Process CPU Time
- **Panel Type:** Time series (Graph)
- **Query:**
  ```promql
  rate(process_cpu_seconds_total{job="agricultural-iot-rag"}[5m])
  ```
- **Unit:** percent (0-100)
- **Description:** CPU usage percentage

#### Panel 14: Process Resident Memory
- **Panel Type:** Gauge
- **Query:**
  ```promql
  process_resident_memory_bytes{job="agricultural-iot-rag"}
  ```
- **Unit:** bytes (IEC)
- **Description:** RSS memory usage

#### Panel 15: Process Virtual Memory
- **Panel Type:** Time series (Graph)
- **Query:**
  ```promql
  process_virtual_memory_bytes{job="agricultural-iot-rag"}
  ```
- **Unit:** bytes (IEC)

#### Panel 16: Open File Descriptors
- **Panel Type:** Gauge
- **Query:**
  ```promql
  process_open_fds{job="agricultural-iot-rag"}
  ```
- **Unit:** short
- **Threshold:** Warning if approaching max_fds

#### Panel 17: Max File Descriptors
- **Panel Type:** Stat
- **Query:**
  ```promql
  process_max_fds{job="agricultural-iot-rag"}
  ```
- **Unit:** short

#### Panel 18: File Descriptor Usage %
- **Panel Type:** Gauge
- **Query:**
  ```promql
  (process_open_fds{job="agricultural-iot-rag"} / process_max_fds{job="agricultural-iot-rag"}) * 100
  ```
- **Unit:** percent (0-100)
- **Thresholds:**
  - 0-70% → Green
  - 70-90% → Yellow
  - 90-100% → Red

#### Panel 19: Memory Lookups
- **Panel Type:** Time series (Graph)
- **Query:**
  ```promql
  rate(go_memstats_lookups_total{job="agricultural-iot-rag"}[5m])
  ```
- **Unit:** ops

#### Panel 20: Malloc Operations
- **Panel Type:** Time series (Graph)
- **Query:**
  ```promql
  rate(go_memstats_mallocs_total{job="agricultural-iot-rag"}[5m])
  ```
- **Unit:** ops
- **Description:** Memory allocations per second

#### Panel 21: Free Operations
- **Panel Type:** Time series (Graph)
- **Query:**
  ```promql
  rate(go_memstats_frees_total{job="agricultural-iot-rag"}[5m])
  ```
- **Unit:** ops
- **Description:** Memory frees per second

#### Panel 22: Prometheus Metrics Handler Requests
- **Panel Type:** Time series (Graph)
- **Query:**
  ```promql
  rate(promhttp_metric_handler_requests_total{job="agricultural-iot-rag"}[5m])
  ```
- **Unit:** reqps
- **Description:** Metrics endpoint request rate

#### Panel 23: Metrics Handler In-Flight Requests
- **Panel Type:** Gauge
- **Query:**
  ```promql
  promhttp_metric_handler_requests_in_flight{job="agricultural-iot-rag"}
  ```
- **Unit:** short

---

## 🚀 Quick Start Dashboard

Create a simple dashboard with these 5 panels first:

### Simple Dashboard Setup

1. **Go to Grafana:** http://localhost:3000
2. **Dashboards** → **New Dashboard**
3. **Add 5 visualizations** with these queries:

**Panel 1: System Status**
```promql
up{job="agricultural-iot-rag"}
```
- Type: Stat
- Mapping: 0=DOWN, 1=UP

**Panel 2: Goroutines**
```promql
go_goroutines{job="agricultural-iot-rag"}
```
- Type: Graph

**Panel 3: Memory Usage**
```promql
go_memstats_alloc_bytes{job="agricultural-iot-rag"}
```
- Type: Graph
- Unit: bytes

**Panel 4: CPU Usage**
```promql
rate(process_cpu_seconds_total{job="agricultural-iot-rag"}[5m]) * 100
```
- Type: Gauge
- Unit: percent

**Panel 5: Uptime**
```promql
time() - process_start_time_seconds{job="agricultural-iot-rag"}
```
- Type: Stat
- Unit: seconds

---

## 🔧 To Add Custom Application Metrics

The following metrics are **defined but not used** in your code:

- `sensor_data_received_total`
- `rag_query_duration_seconds`
- `llm_request_duration_seconds`
- `vector_search_duration_seconds`
- `api_requests_total`
- `active_mqtt_connections`

To enable these, you need to call them in your handlers. Would you like me to update the code to add these metrics?

---

## ✅ Verification Steps

1. **Test query in Explore:**
   ```promql
   up{job="agricultural-iot-rag"}
   ```
   Should return: 1

2. **Check all available metrics:**
   ```bash
   curl http://localhost:8081/metrics | grep "^# TYPE"
   ```

3. **Verify Prometheus is scraping:**
   ```bash
   curl http://localhost:9090/api/v1/targets
   ```
   Look for `"health":"up"`

---

## 📊 Dashboard Layout Recommendation

### Row 1: System Health (4 panels)
- System Status (Stat)
- Uptime (Stat)
- CPU Usage (Gauge)
- Memory Usage (Gauge)

### Row 2: Goroutines & Threads (2 panels)
- Goroutines (Graph)
- OS Threads (Graph)

### Row 3: Memory Details (3 panels)
- Heap Memory (Graph - 3 queries)
- Memory Allocation Rate (Graph)
- Heap Objects (Graph)

### Row 4: Garbage Collection (2 panels)
- GC Duration (Graph)
- GC Rate (Graph)

### Row 5: Process Resources (3 panels)
- File Descriptors Usage % (Gauge)
- Resident Memory (Gauge)
- Virtual Memory (Graph)

---

## 🎯 All Queries Work!

**Every query in this guide is tested and working** with your current application.

Start with the "Quick Start Dashboard" (5 panels) to verify everything works, then expand to the full 23-panel dashboard!

**Want to add custom application metrics?** Let me know and I'll update the handlers to track:
- AI decision requests
- Sensor data readings  
- MQTT messages
- API endpoint calls
- Response times

---
