#!/bin/bash

# Stop All Services Script

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              🛑 STOPPING ALL SERVICES                          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Stop Go server
if [ -f server.pid ]; then
    PID=$(cat server.pid)
    echo "🛑 Stopping Go server (PID: $PID)..."
    kill $PID 2>/dev/null && echo "✅ Server stopped" || echo "ℹ️  Server was not running"
    rm -f server.pid
else
    echo "ℹ️  No server.pid found, checking for running process..."
    pkill -f './bin/server' && echo "✅ Server stopped" || echo "ℹ️  No server was running"
fi

# Stop Docker services
echo ""
echo "🛑 Stopping Docker services..."
docker compose down

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                ✅ ALL SERVICES STOPPED                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "To restart: ./scripts/restart.sh"
echo ""
