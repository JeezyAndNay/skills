# Template Python Skill

Minimal Python skill template using Flask. Accepts JSON POSTs at `/run` and
returns the input as JSON. Good starting point for HTTP-based Claude skills.

Run locally:

1. Create a virtualenv and install dependencies:

   python -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt

2. Start:

   python handler.py

Test:

```bash
curl -X POST http://localhost:3001/run -H "Content-Type: application/json" \
  -d '{"example":"value"}'
```
