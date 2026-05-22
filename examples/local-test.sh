#!/usr/bin/env bash

echo "Testing Node template (port 3000)..."
curl -s -X POST http://localhost:3000/run -H "Content-Type: application/json" -d '{"test":"node"}' | jq || true

echo
echo "Testing Python template (port 3001)..."
curl -s -X POST http://localhost:3001/run -H "Content-Type: application/json" -d '{"test":"python"}' | jq || true
