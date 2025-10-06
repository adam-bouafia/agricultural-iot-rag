# Documentation Index

## 📚 Core Documentation

### Getting Started
- **[README.md](README.md)** - Project overview, features, and architecture
- **[QUICKSTART.md](QUICKSTART.md)** - 5-minute quick start guide

### System Understanding
- **[SYSTEM_EXPLANATION.md](SYSTEM_EXPLANATION.md)** - Detailed system execution flow
- **[KNOWLEDGE_GUIDE.md](KNOWLEDGE_GUIDE.md)** - How the RAG system works

### Monitoring & Observability
- **[GRAFANA_SETUP.md](GRAFANA_SETUP.md)** - Grafana dashboard setup instructions
- **[GRAFANA_WORKING_METRICS.md](GRAFANA_WORKING_METRICS.md)** - Complete list of available Prometheus metrics and panel configurations

---

## 🎯 Document Purpose

| Document | Purpose | Audience |
|----------|---------|----------|
| README.md | Project introduction, features, architecture | Everyone |
| QUICKSTART.md | Get system running in 5 minutes | New users |
| SYSTEM_EXPLANATION.md | Technical deep-dive into system flow | Developers |
| KNOWLEDGE_GUIDE.md | RAG system explanation with examples | Users/Developers |
| GRAFANA_SETUP.md | Dashboard setup walkthrough | Operators |
| GRAFANA_WORKING_METRICS.md | Metrics reference and panel configs | DevOps/SRE |

---

## 🚀 Recommended Reading Order

### For First-Time Users:
1. README.md → Learn what the system does
2. QUICKSTART.md → Get it running
3. KNOWLEDGE_GUIDE.md → Understand how AI works

### For Developers:
1. README.md → Overview
2. SYSTEM_EXPLANATION.md → Technical architecture
3. KNOWLEDGE_GUIDE.md → RAG implementation

### For Operations/Monitoring:
1. QUICKSTART.md → Get system running
2. GRAFANA_SETUP.md → Set up monitoring
3. GRAFANA_WORKING_METRICS.md → Configure dashboards

---

## 🔍 What You're Seeing in the Terminal

If you see logs like this:
```
[GIN] 2025/10/06 - 06:40:19 | 200 | 481.41µs | 172.20.0.4 | GET "/metrics"
```

**This is GOOD!** It means:
- ✅ Prometheus is successfully scraping your metrics
- ✅ Happens every 15 seconds (default scrape interval)
- ✅ 172.20.0.4 is the Prometheus container IP
- ✅ 200 status = successful request
- ✅ ~500µs = very fast response time

**These logs are normal and expected.** They show your monitoring is working correctly.

To reduce log verbosity, you can set Gin to release mode (already done in production).

---

## 📖 API Documentation

See [docs/API.md](docs/API.md) for complete API reference.

---

## 🛠️ Configuration Files

- `docker-compose.yml` - Service orchestration
- `deployments/prometheus.yml` - Prometheus configuration
- `deployments/mosquitto.conf` - MQTT broker configuration
- `deployments/grafana-dashboards/` - Pre-built Grafana dashboards
- `.env` - Environment variables (not in git)

---

## 🤝 Contributing

When adding new documentation:
1. Keep it focused on one topic
2. Add it to this index
3. Update the recommended reading order if needed
4. Include practical examples
5. Keep language clear and concise

---

## 📝 Documentation Standards

- Use clear headings (H1 for title, H2 for sections)
- Include code examples with syntax highlighting
- Add emoji for visual guidance (✅❌⚠️🎯)
- Provide troubleshooting sections
- Keep it up-to-date with code changes

---

Last Updated: October 6, 2025
