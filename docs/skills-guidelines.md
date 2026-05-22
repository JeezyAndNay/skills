# Skill Manifests & Guidelines

Guidelines for creating skills in this repo:

- Keep `manifest.json` minimal: `name`, `description`, and input schema.
- Implement an HTTP `POST /run` endpoint that accepts JSON and returns JSON.
- Do not commit secrets — use environment variables or a secrets manager.
- Add a `README.md` for each skill with setup and example requests.
