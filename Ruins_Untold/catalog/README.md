# Ruins Untold — Idea Catalog

**Type:** n8n Workflow  
**Trigger:** Manual (on demand)  
**Output:** New unique video ideas appended to Google Sheets with status tracking

---

## What It Does

Runs the RU_ideas prompt via Claude API, checks every generated idea against the catalog for duplicates, and writes only net-new ideas to Google Sheets — each with a `STATUS` of **New**.

The sheet is the single source of truth for the production pipeline:

```
Idea Catalog workflow  →  Google Sheet (status: New → In Progress → Complete)
                                       ↓
                          Production workflow (picks up "In Progress" rows)
```

---

## Google Sheet Setup

### 1. Create the spreadsheet

Create a new Google Sheet. Name the first tab exactly: **`Ideas`**

Add this header row in row 1 (exact column order matters):

| A | B | C | D | E | F | G | H | I | J | K |
|---|---|---|---|---|---|---|---|---|---|---|
| `ID` | `DATE_ADDED` | `STATUS` | `TOPIC` | `ANGLE` | `KEY_EVIDENCE` | `KEY_RESEARCHERS` | `HOOK_STYLE` | `TONE_DIAL` | `RELATED_VIDEO` | `NOTES` |

### 2. Add the ID formula

In cell **A2**, enter this formula and drag it down for ~500 rows:
```
=IF(D2="","",ROW()-1)
```
This auto-assigns an ID to every row that has a topic, leaving blank rows clean.

### 3. Add status dropdown validation

Select column C (STATUS), then **Data → Data Validation → Dropdown**. Add these three options:
- `New`
- `In Progress`
- `Complete`

### 4. Freeze the header row

**View → Freeze → 1 row** — keeps the header visible while scrolling.

### 5. Copy the spreadsheet ID

The spreadsheet ID is the long string in the URL between `/d/` and `/edit`:
```
https://docs.google.com/spreadsheets/d/YOUR_SPREADSHEET_ID_HERE/edit
```

---

## n8n Setup

### 1. Create Google Sheets credential

In n8n: **Settings → Credentials → New → Google Sheets OAuth2 API**

Authenticate your Google account. Note the credential ID — you'll need it in step 4.

### 2. Set your Anthropic API key as an environment variable

In n8n: **Settings → Environment Variables** → add:
```
ANTHROPIC_API_KEY = your_key_here
```

### 3. Import the workflow

In n8n: **Workflows → Import from file** → select `n8n-workflow.json`

### 4. Configure the two required values

**A. Spreadsheet ID** — in the **Config** node, replace `YOUR_GOOGLE_SHEET_ID_HERE` with your actual spreadsheet ID from step 1.5 above.

**B. Google credential** — both **Read Existing Topics** and **Write to Catalog** nodes have a credential placeholder. Open each node → Credential field → select your Google Sheets OAuth2 credential.

### 5. Save and test

Click **Execute Workflow**. On the first run the sheet is empty, so all generated ideas will be written. On subsequent runs, duplicates are filtered before writing.

---

## Workflow Logic

```
Manual Trigger
    │
    ▼
Config
  spreadsheetId, sheetName, ideasCount (default: 10)
    │
    ▼
Generate Ideas via Claude   ←── Claude API, claude-opus-4-5
  System prompt: RU_ideas adapted for JSON output
  Returns: JSON array of 10 ideas
    │
    ▼
Parse Ideas                 ←── Code node
  Extracts JSON array from Claude response
  Normalizes field names
  Outputs each idea as a separate item
    │
    ▼
Read Existing Topics        ←── Google Sheets read
  Reads all rows from the Ideas tab
  Passes full row data downstream
    │
    ▼
Filter Duplicates           ←── Code node
  Exact match on TOPIC (case-insensitive)
  Keyword overlap check: flags duplicate if ≥60% of significant
  words in new topic match an existing topic
  Passes only net-new ideas
    │
    ▼
Any New Ideas?              ←── IF node
  TRUE  → Write to Catalog
  FALSE → Nothing New to Add (no-op)
    │
    ▼
Write to Catalog            ←── Google Sheets append
  DATE_ADDED: today's date
  STATUS:     New
  All idea fields mapped to columns
```

---

## Spreadsheet Columns

| Column | Type | Description |
|---|---|---|
| `ID` | Auto (formula) | Row number, auto-assigned |
| `DATE_ADDED` | Date | Date the idea was generated |
| `STATUS` | Dropdown | `New` / `In Progress` / `Complete` |
| `TOPIC` | Text | Episode title (5–10 words) — the dedup key |
| `ANGLE` | Text | 3–5 sentence pitch |
| `KEY_EVIDENCE` | Text | Named sources, papers, artifacts, dates |
| `KEY_RESEARCHERS` | Text | Named researchers — includes at least one antagonist |
| `HOOK_STYLE` | Text | `question` / `statement` / `contradiction` / `anomaly` / `revelation` |
| `TONE_DIAL` | Number | 1–10, default 6–7 |
| `RELATED_VIDEO` | Text | Related episode or "none yet" |
| `NOTES` | Text | Free-text production notes — fill in manually |

---

## Deduplication Logic

Two-pass check before any idea is written:

**Pass 1 — Exact match**
Compares the new topic string (lowercase, trimmed) against all existing `TOPIC` values. Drops exact matches.

**Pass 2 — Keyword overlap**
Extracts significant words (length > 3, not stop words) from each topic. Flags a new idea as duplicate if ≥60% of its significant words appear in any existing topic. This catches near-matches like:
- `"The Smithsonian Hid This"` vs `"Smithsonian's Hidden Evidence"` → duplicate
- `"Antikythera Device"` vs `"Baghdad Battery"` → not duplicate

---

## Status Workflow

| Status | Meaning | Who sets it |
|---|---|---|
| `New` | Idea generated, not yet started | Workflow (automatic) |
| `In Progress` | Script or production has begun | You (manually in sheet) |
| `Complete` | Episode published | You (manually in sheet) or production workflow |

The production workflow should filter for `STATUS = "In Progress"` to pick up the next episode in the queue.

---

## Tuning

**Change how many ideas are generated per run:**
In the **Config** node, update `ideasCount` (default: 10). Values between 5–20 work reliably.

**Change the Claude model:**
In the **Generate Ideas via Claude** node, update `model`. Recommended options:
- `claude-opus-4-5` — highest quality ideas (default)
- `claude-sonnet-4-5` — faster, slightly less depth

**Adjust dedup sensitivity:**
In the **Filter Duplicates** code node, change the `0.6` threshold:
- Lower (e.g. `0.5`) = stricter dedup, fewer ideas pass through
- Higher (e.g. `0.75`) = looser dedup, more ideas pass through

---

## Connecting to the Production Workflow

The production workflow reads from this sheet by filtering `STATUS = "In Progress"`. When you're ready to produce an episode:

1. Find the idea in the sheet
2. Change its `STATUS` from `New` to `In Progress`
3. Trigger the production workflow — it will pick up that row

The `TOPIC`, `ANGLE`, `KEY_EVIDENCE`, and `KEY_RESEARCHERS` columns feed directly into the script generation prompt.

---

## Related

| File | Description |
|---|---|
| [`../RU_ideas/SKILL.md`](../RU_ideas/SKILL.md) | The Claude Code skill this workflow is based on |
| [`../ruins_untold_script_node.md`](../ruins_untold_script_node.md) | n8n script generation node for the production workflow |
