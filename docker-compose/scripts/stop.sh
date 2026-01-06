#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "Stopping all services..."
docker compose down

echo ""
echo "All services stopped."
echo ""
echo "To also remove volumes (databases, vault data, minio data):"
echo "  docker compose down -v"
echo ""
