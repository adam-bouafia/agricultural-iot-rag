#!/bin/bash

# System Restart Script
# Stops all services then performs a clean start

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        🔄 RESTARTING Agricultural IoT RAG System 🔄            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Stop everything first
echo "🛑 Stopping all services..."
./scripts/stop.sh

echo ""
echo "⏳ Waiting 5 seconds before restart..."
sleep 5
echo ""

# Start everything fresh
./scripts/start.sh
