# EnergyGuard AI Risk Database

EnergyGuard is a curated database and API exposing canonical AI risk cards for energy-sector assessments. It provides a Postgres-backed data model with JSONB risk cards, FastAPI-powered services, CLI tooling for editorial workflows, and daily JSON/CSV exports suitable for TEF/ALTAI integration.

## Features

- **Relational schema + JSONB cards** with automated `updated_at` trigger and GIN index for search.
- **REST API** for listing, filtering, and managing risk cards with optional API token security.
- **CSV importer** implementing deterministic merge/provenance rules for canonical risk seeds.
- **Editorial utilities** for quarterly review feeds and provenance stamping.
- **Automated exports** that persist daily JSON/CSV snapshots with 14-day retention.
- **TEF/ALTAI hooks** including stable IDs, brief listings, and batch fetch support.

## Project Structure

```
app/
  api/                FastAPI routers and dependencies
  cli/                Typer commands for ingestion and review
  core/               Settings and configuration helpers
  db/                 SQLAlchemy models, sessions, and init helpers
  schemas/            Pydantic models for validation and responses
  services/           Business logic, exports, and risk services
exports/              Default export directory (mounted in containers)
seed_canonical_risks.csv  Curated 24-card seed set
```

## Prerequisites

- Python 3.11+
- Docker (for containerized setup)
- Postgres 15+ (if running locally without Docker)

## Local Development

1. **Create a virtual environment and install dependencies**
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

2. **Configure environment**
   ```bash
   cp .env.example .env
   # set POSTGRES_PASSWORD and update DATABASE_URL, API_TOKEN, PROVENANCE_EDITOR as needed
   ```

3. **Provision the database schema**
   ```bash
   python -m app.db.init_db
   ```

4. **Run the API**
   ```bash
   uvicorn app.main:app --reload
   ```

   The interactive OpenAPI documentation is available at [http://localhost:8000/docs](http://localhost:8000/docs).

## Docker Compose

A complete stack (Postgres + API) is defined via Docker Compose.

```bash
docker compose up --build
```

- API service: <http://localhost:8000>
- Postgres: exposed on port `5432`. Set `POSTGRES_PASSWORD` (and optionally `POSTGRES_USER`/`POSTGRES_DB`) in your `.env` before
  running `docker compose`.
- Exports are written to `./exports` and refreshed daily by the in-app scheduler.

## Seeding Canonical Risks

The repository includes `seed_canonical_risks.csv` covering 24 canonical risks aggregated from MITRE ATLAS, MIT AI Risk, and AIID. Ingest with the Typer CLI:

```bash
python manage.py ingest canonical-seed --file seed_canonical_risks.csv
```

The importer enforces:

- `EG-R-\d{4,}` risk ID pattern.
- Probability/impact/operational priority levels between 1–5.
- Deterministic merge heuristic using normalized title + description hash (`merge_hash`).
- Provenance array format such as `"merged: MITRE_ATLAS:TP-004 | AIID:INC-233 | MIT_AIRISK:bias | editor:ICCS | date:2025-10-27"`.
- Automatic deduplication updates for repeated ingests without creating duplicate rows.

### Editorial Review Feed

Identify gaps for quarterly curation cycles:

```bash
python manage.py review feed > review_gaps.csv
```

This CSV lists risk cards missing `known_mitigations`, `source_reference`, or level scores to support follow-up edits.

## API Overview

### List and Search Risks

```bash
curl "http://localhost:8000/risks?q=forecast&min_impact=4&limit=20"
```

Supports free-text search over card content, minimum impact filters, and `ids=EG-R-0001,EG-R-0005` batching for TEF integrations.

### Retrieve a Single Risk

```bash
curl http://localhost:8000/risks/EG-R-0007
```

### Create / Update / Patch (with optional API token)

```bash
curl -X POST http://localhost:8000/risks \ 
  -H "Content-Type: application/json" \ 
  -H "X-API-Key: <token>" \ 
  -d @new_risk.json
```

`POST`, `PUT`, and `PATCH` endpoints append provenance entries documenting editor, action, and timestamp.

### Export Endpoints

- `GET /export/json` – JSON dump of all risks.
- `GET /export/csv` – Flattened CSV (arrays joined by `;`).

Daily background jobs also write `exports/eg_risks.json`, `exports/eg_risks.csv`, and timestamped snapshots retained for 14 days.

### TEF / ALTAI Hooks

- Every card exposes `stable_id == risk_id` for UI clarity.
- `GET /risks/brief` returns `risk_id`, `risk_name`, `impact_level`, and `impact_dimensions` for dropdown population.
- `GET /risks?ids=...` enables batch retrieval for TEF forms.
- TEF forms can persist `risk_id` references and retrieve full context via `GET /risks/{risk_id}`.

## Security

Set `API_TOKEN` (or `X-API-Key` header) to require authentication on mutating endpoints. Missing or incorrect tokens result in `401 Unauthorized`. Provenance entries capture editor/timestamp metadata for governance reporting.

### GitHub Secrets (CI/CD)

If you run automated deployments or scheduled ingests from GitHub Actions, add the required environment variables as [repository secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) instead of committing them.

| Secret name | Description | Example value* |
| --- | --- | --- |
| `POSTGRES_USER` | Database role used by the API and import jobs. | `energy_guard_app` |
| `POSTGRES_PASSWORD` | Strong password for `POSTGRES_USER`. | `generate-a-32-char-random-string` |
| `POSTGRES_DB` | Database name for the EnergyGuard schema. | `energy_guard` |
| `DATABASE_URL` | Full SQLAlchemy connection string referencing the same credentials. | `postgresql+psycopg2://energy_guard_app:${{ secrets.POSTGRES_PASSWORD }}@db:5432/energy_guard` |
| `API_TOKEN` *(optional)* | Token required for POST/PUT/PATCH requests when API key enforcement is enabled. | `use-a-unique-token-for-ci` |
| `PROVENANCE_EDITOR` | Short code recorded in provenance trails for automated edits. | `ICCS-AUTOMATION` |
| `PROVENANCE_DOMAIN` *(optional)* | Domain or organization label for provenance. | `ICCS` |

\*Replace example placeholders with real, project-specific values before use. Avoid copying these samples verbatim into production systems.

Reference the secrets inside workflow files using `${{ secrets.NAME }}` to keep credentials out of version control. Populate your runtime `.env` from the same secrets during deployment so that local `.env.example` placeholders never leak into logs or artifacts.

## Provenance & Merge Policy

- **One risk concept per card** – importer merges rows sharing normalized title/description hash.
- **Provenance** is tracked as an array of strings documenting merged sources, editors, and dates.
- **Source references** aggregate all contributing canonical IDs (e.g., `MITRE_ATLAS`, `AIID`).

## Exports & Persistence

- Exports write to `/exports` (configurable) and persist across container restarts when mounted.
- Timestamped daily exports (`eg_risks_YYYYMMDD.json/csv`) are pruned after 14 days.

## Running Tests

```bash
pytest
```

Tests validate schema constraints, search and filter behavior, importer idempotency, and export parity with the database count (using a temporary SQLite database for convenience).

## License

Released under the MIT license. See [LICENSE](LICENSE) for details.
