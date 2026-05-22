# Personal Claude Skills

A collection of custom, personal skills for Claude (Anthropic) — small, focused tools
that extend Claude with bespoke actions, data connectors, and automations.

**Purpose:** centralize my personal Claude skills, examples, and development notes so
I can quickly iterate, test, and share helper skills.

**Status:** experimental — use at your own risk.

**Table of contents**
- Overview
- Getting started
- Structure
- Creating a skill
- Testing locally
- Deploying & using
- Security & privacy
- Examples
- Contributing
- License

**Overview**
- **What these are:** small programs (HTTP endpoints, scripts, or adapters) that
	implement a well-defined action Claude can call when given permission.
- **Intended use:** personal automations, data lookups, and safe integrations where
	you control the code and data.

**Getting started**
- **Requirements:** Git, Node.js >= 18 (or Python 3.10+ depending on implementations),
	and any cloud or local runtime you prefer for hosting HTTP-based skills.
- **Clone:**

	git clone https://github.com/UncleJeezyandLadyNay/skills.git

- Work from the `main` branch for personal experiments.

**Structure**
- **`skills/`**: skill folders (each skill is self-contained).
- **`examples/`**: example skill implementations and curl/test scripts.
- **`docs/`**: notes and local docs about skill manifests and development.
- **`README.md`**: this file.

Each skill folder typically contains:
- `manifest.json` — skill metadata (name, description, inputs, auth hints).
- `handler.js` or `handler.py` — the executable entrypoint (HTTP or CLI).
- `README.md` — skill-specific usage and configuration.

**Creating a skill**
1. Create a new folder in `skills/your-skill-name`.
2. Add a `manifest.json` with a concise `name`, `description`, `inputs` schema,
	 and any `auth` or `secrets` required.
3. Implement the handler (`handler.js` / `handler.py`) that accepts input and
	 returns structured output (JSON). Prefer HTTP endpoints for easy testing.
4. Add an example request in the skill `README.md`.

Minimal `manifest.json` example:

```json
{
	"name": "weather-lookup",
	"description": "Return current weather for a location",
	"inputs": {
		"type": "object",
		"properties": {"location": {"type": "string"}},
		"required": ["location"]
	}
}
```

**Testing locally**
- Run your handler locally behind a tunneling tool (ngrok, localtunnel) if you
	want Claude to call it from the cloud.
- Test via `curl` or a small test harness in `examples/`.

Example test (Node.js express handler listening on 3000):

```bash
curl -X POST http://localhost:3000/run -H "Content-Type: application/json" \
	-d '{"location":"Paris,FR"}'
```

**Deploying & using**
- Deploy an HTTP-accessible endpoint (serverless, small VM, or container).
- Share the endpoint and `manifest.json` with Claude as a skill definition,
	following Anthropic's skill/tool registration format if using an official flow.
- Keep secrets out of repo — use environment variables or secret managers.

**Security & privacy**
- Treat skill endpoints as code you control — validate all inputs and rate-limit
	where appropriate.
- Do not store or expose sensitive data in logs or in the repo.
- Prefer ephemeral API keys and limit scopes for any third-party services.

**Examples**
- `skills/weather-lookup`: a minimal HTTP skill that proxies a weather API.
- `examples/local-test.sh`: curl-based tests to exercise a running skill.

**Contributing (personal workflow)**
- Add new skills under `skills/` with a `manifest.json` and `README.md`.
- Keep changes small and test locally before pushing.

**License**
- This is a personal collection; pick a license or mark as private. No license
	is specified by default.

---

If you'd like, I can scaffold a new skill template in `skills/` and an example
test harness — tell me the language you prefer (Node or Python).
