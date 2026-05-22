# Template Node Skill

Minimal Node.js skill template that accepts JSON POSTs at `/run` and echoes
the input back as JSON. Useful as a starting point for HTTP-based Claude skills.

Run locally:

1. Install dependencies:

   npm install

2. Start:

   npm start

Test:

```bash
curl -X POST http://localhost:3000/run -H "Content-Type: application/json" \
  -d '{"example":"value"}'
```
