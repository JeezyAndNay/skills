# Ruins Untold — Production Pipeline

**Type:** n8n Workflow + Python Generator  
**Trigger:** Manual execution — picks a topic from your `Ruins_Untold_Ideas` Google Sheet  
**Output:** Complete episode package — script → voiceover → 224 visual prompts → music/SFX cues → thumbnail prompts → ready-to-run FFmpeg assembly script

---

## What It Does

A full end-to-end YouTube episode production system for **The Ruins Untold** — a faceless channel covering ancient mysteries, forbidden archaeology, and alternative history.

You connect your ideas sheet, pick a topic, and the pipeline handles everything else:

```
Google Sheet (Ruins_Untold_Ideas)
        │   pick 1 of 10 topics
        ▼
n8n Workflow
  ├── Claude generates 20-min script
  ├── Human review + approval gate
  ├── ElevenLabs generates voiceover
  ├── Human review + approval gate
  ├── gen_asset_prompts.py runs against the SRT transcript:
  │     ├── 168 image prompts (XLSX, NB2 format)
  │     ├── 56 video prompts  (XLSX, NB2 format)
  │     ├── 7  music cues     (XLSX, Suno format)
  │     ├── 9  SFX cues       (XLSX, Suno format)
  │     ├── 3  thumbnail prompts (XLSX, NB2 12-field JSON)
  │     ├── drift_check.xlsx  (narration vs visual alignment QA)
  │     └── assemble.sh       (zero-drift FFmpeg assembly)
  ├── Human generates images/videos in external AI tools
  ├── Human review + final approval gate
  └── FFmpeg assembles final video
```

The pipeline pauses at three human review gates — script, voiceover, and final assets — before proceeding. No step runs unattended past a gate.

---

## Files in This Folder

| File | Description |
|---|---|
| `n8n-workflow.json` | Import this into n8n. Full 48-node production pipeline. |
| `gen_asset_prompts.py` | Python script that converts a Whisper SRT transcript into every prompt file and the FFmpeg assembly script. Run once per episode. |
| `channel_config.json` | Channel-level constants (style, palette, lighting, timing, thumbnail rules). Read by `gen_asset_prompts.py` at runtime. |

---

## Prerequisites

| Tool | Purpose | Notes |
|---|---|---|
| [n8n](https://n8n.io) | Workflow automation | Self-hosted or cloud |
| Python 3.11+ | Runs `gen_asset_prompts.py` | `pip install openpyxl` |
| [whisper-cpp](https://github.com/ggerganov/whisper.cpp) | Transcribes voiceover to SRT | See transcription config below |
| [FFmpeg](https://ffmpeg.org) | Final video assembly | Must be in PATH |
| Claude API key | Script generation | `claude-opus-4-5` or higher |
| ElevenLabs API key | Voiceover TTS | Any plan |
| Google Sheets OAuth2 | Reads your ideas sheet | Setup in n8n credentials |

---

## Setup

### 1. Install Python dependencies

```bash
pip install openpyxl
```

### 2. Configure whisper-cpp

The generator expects a Whisper SRT transcript at `{PROJ}/scripts/voiceover_transcript.srt`.

Default transcription config (from `channel_config.json`):

```json
"transcription": {
  "binary":    "/usr/local/opt/whisper-cpp/bin/whisper-cli",
  "model":     "ggml-base.en.bin",
  "model_path": "/usr/local/share/whisper-cpp/ggml-base.en.bin",
  "flags":     "--language en -ml 80 -sow -osrt -t 8"
}
```

To transcribe your voiceover:
```bash
/usr/local/opt/whisper-cpp/bin/whisper-cli \
  --language en -ml 80 -sow -osrt -t 8 \
  --model /usr/local/share/whisper-cpp/ggml-base.en.bin \
  {PROJ}/audio/voiceover.mp3
```

This produces `voiceover_transcript.srt` next to the audio file. Move it to `{PROJ}/scripts/` before running the generator.

### 3. Create Google Sheets credential in n8n

**Settings → Credentials → New → Google Sheets OAuth2 API**

Authenticate your Google account. n8n will assign a credential ID.

### 4. Set up your `Ruins_Untold_Ideas` sheet

The workflow reads the first 10 data rows from this sheet. Required column order (row 1 = headers):

| A | B | C | D | E | F | G |
|---|---|---|---|---|---|---|
| `TOPIC` | `ANGLE` | `KEY_EVIDENCE` | `KEY_RESEARCHERS` | `RELATED_VIDEO` | `HOOK_STYLE` | `TONE_DIAL` |

> **Tip:** Use the [Catalog workflow](../catalog/) to auto-populate this sheet from Claude-generated ideas.

Copy the spreadsheet ID from the URL:
```
https://docs.google.com/spreadsheets/d/YOUR_SPREADSHEET_ID/edit
```

### 5. Import the workflow

In n8n: **Workflows → Import from file** → select `n8n-workflow.json`

### 6. Configure the two required nodes

Open the workflow and update:

**`Read Ruins Untold Ideas` node:**
- `documentId.value` → your spreadsheet ID from step 4
- Credential → select your Google Sheets OAuth2 credential

**`Generate Voiceover — ElevenLabs` node:**
- Credential → select your ElevenLabs API Key credential (already wired — just needs the credential assigned)

Everything else references those two values downstream. No other nodes need manual edits.

### 7. Update `channel_config.json`

Set the paths to match your environment:

```json
"transcription": {
  "binary":     "/path/to/your/whisper-cli",
  "model_path": "/path/to/your/ggml-base.en.bin"
}
```

And update the `pinned_clips` asset path for the channel intro:
```json
"pinned_clips": [{
  "asset_path": "/path/to/your/channel_intro.mp4"
}]
```

---

## Running an Episode

### Step 1 — Select your topic

Click **Execute Workflow** in n8n. The workflow reads your first 10 ideas and shows a form:

```
Available topics from Ruins_Untold_Ideas:

1. The Smithsonian Destroyed Giants: Their Own Records Prove It
2. Göbekli Tepe Was Deliberately Buried — But Who Ordered It?
3. ...

Enter the number of the topic you want to develop.
VOICE_ID: [ElevenLabs voice ID]
```

Submit the form. The pipeline runs from here.

### Step 2 — Review the script

The workflow pauses at a **Script Review & Approval** gate. Check the saved script file at:
```
{projectDir}/scripts/voiceover_script.txt
```

Return to the n8n execution and either:
- **Approve** → continues to voiceover generation
- **Revise** → sends revision notes back to Claude for a rewrite

### Step 3 — Review the voiceover

The workflow pauses at a **Voiceover Review & Approval** gate. Listen to:
```
{projectDir}/audio/voiceover.mp3
```

Approve to continue, or flag for revision.

### Step 4 — Transcribe the voiceover

After approval, run Whisper against your voiceover:
```bash
whisper-cli --language en -ml 80 -sow -osrt -t 8 \
  --model /path/to/ggml-base.en.bin \
  {projectDir}/audio/voiceover.mp3
mv {projectDir}/audio/voiceover_transcript.srt {projectDir}/scripts/
```

### Step 5 — Run the asset prompt generator

```bash
python3 gen_asset_prompts.py \
  --proj "/path/to/your/episode/project" \
  --topic "Your Episode Title"
```

Output (all written to `{PROJ}/scripts/`):

| File | Contents |
|---|---|
| `timed_transcript.txt` | Cleaned, merged narration with timestamps |
| `asset_prompts.json` | Master JSON — all image/video/music/SFX prompts |
| `image_prompts.xlsx` | 168 image prompts in NB2 format |
| `video_prompts.xlsx` | 56 video prompts in NB2 format |
| `music_prompts.xlsx` | 7 music cues in Suno prompt format |
| `sfx_prompts.xlsx` | 9 SFX cues in Suno prompt format |
| `drift_check.xlsx` | Narration ↔ visual alignment QA — flagged mismatches highlighted |
| `thumbnail_prompts.xlsx` | 3 thumbnail variants with full NB2 JSON + text suggestions |
| `media_placement.json` | Full timeline — every clip's filename, timestamp, duration |
| `assemble.sh` | FFmpeg script — zero-drift, ready to run |

### Step 6 — Generate media

Open `image_prompts.xlsx` and `video_prompts.xlsx`. Generate each asset in your preferred AI image/video tool (Midjourney, Flux, Kling, Runway, etc.). Save to:

```
{projectDir}/images/image_0001.png  … image_0168.png
{projectDir}/videos/video_0001.mp4  … video_0056.mp4
```

> **Pinned assets:** The channel intro clip is automatically assigned to `video_0004.mp4`. Copy your intro file to that path before assembling.

### Step 7 — Return to n8n and approve assets

Return to the **Assets Review & Final Approval** gate in n8n and approve.

### Step 8 — Assemble

```bash
bash {projectDir}/scripts/assemble.sh
```

The FFmpeg script handles:
- Scaled image durations (zero drift — video length matches voiceover exactly)
- J-cut audio lead (1.5s, configurable in `channel_config.json`)
- Voiceover volume: full until 10:18, then −6 dB for the remainder
- Background music at −12 dB mixed under voiceover
- 0.5s crossfades between all clips

Final output: `{projectDir}_final.mp4`

---

## The Asset Prompt Generator

`gen_asset_prompts.py` is the core of the production system. It runs in 8 sequential steps:

```
STEP 1  Parse SRT → timed_transcript.txt
          Merges short Whisper fragments into readable lines
          Associates each line with a precise timestamp

STEP 2  PROMPT_LIST
          224 manually-written (description, mood) tuples
          Each tuple corresponds to a 7-second cue
          Written directly from the timed transcript — no AI extraction

STEP 3  Visual cue schedule
          168 images + 56 videos (3:1 ratio)
          Every 4th cue is a video
          J-cut applied: narration lookup shifted 1.5s back
          Pinned clips substituted by trigger phrase match

STEP 4  Music & SFX cues
          7 music sections keyed to act structure
          9 SFX hits keyed to dramatic moments

STEP 5  asset_prompts.json
          Master JSON output with all prompt arrays

STEP 6  media_placement.json
          Full timeline for the assembler

STEP 7  XLSX files
          image_prompts.xlsx  — NB2 format
          video_prompts.xlsx  — NB2 format
          music_prompts.xlsx
          sfx_prompts.xlsx
          drift_check.xlsx
          thumbnail_prompts.xlsx

STEP 8  assemble.sh
          FFmpeg concat + filter_complex
          Scaled durations — drift is always ±0.000s
```

### Drift Check

Every cue in `drift_check.xlsx` is tested for visual/narration alignment using two signals:

| Signal | Trigger | What it catches |
|---|---|---|
| **Acronym anchor** | Named acronym in narration (FOIA, NAGPRA, NYT…) not present in visual description | Visual describes the wrong scene during a specific-source callout |
| **Zero word overlap** | Both narration and description have ≥10 content tokens with zero overlap | Completely unrelated visual and speech |

A correctly-written PROMPT_LIST produces ~11 flags. A broken PROMPT_LIST produces 30–50+. Review all `⚠️ DRIFT` rows before generating media.

### J-Cut

The generator applies a 1.5-second J-cut offset: each cue's narration lookup is evaluated at `t − 1.5s`, so the visual description is written against what the viewer hears *just before* the image cuts in. This means audio leads video by 1.5 seconds — the standard editorial J-cut.

Configurable in `channel_config.json`:
```json
"timing": {
  "j_cut_offset_seconds": 1.5
}
```

### Thumbnail Prompts

Three thumbnail variants are generated per episode:

| Variant | Lens | Source range | Subject type |
|---|---|---|---|
| `evidence` | 85mm f/2.8 | First 20% of video | Document / artifact close-up |
| `site` | 24mm f/5.6 | 35–60% of video | Wide archaeological site shot |
| `atmospheric` | 16mm f/8 | Last 12% of video | Silhouette / twilight wide shot |

Each variant outputs:
- Three suppression-register text overlay suggestions (e.g. `THEY DESTROYED THE GIANTS`)
- A full 12-field NB2 JSON prompt, paste-ready for any NB2-compatible image generator
- Individual columns for each NB2 field

Text suggestions use the episode title to extract actor (before the verb) and object (after the verb):
```
"The Smithsonian Destroyed Giants: Their Own Records Prove It"
  → THEY DESTROYED THE GIANTS
  → THE GIANTS THEY DESTROYED
  → SMITHSONIAN DESTROYED THE GIANTS
```

---

## Channel Config

`channel_config.json` drives all style, timing, and thumbnail decisions. Edit once; every episode inherits automatically.

### Key sections

**`style_constants`** — Applied to every image and video prompt:
```json
{
  "style":    "Photorealistic, cinematic, 8K",
  "palette":  ["cinematic teal-orange desaturation", "deep shadow accent", "warm ochre highlights"],
  "lighting": "golden hour sidelighting or deep chiaroscuro shadow",
  "negative": ["no modern elements", "no flat lighting", "no extra limbs", "no motion blur"]
}
```

**`timing`** — Controls cue schedule and assembly:
```json
{
  "image_interval_seconds":    7,
  "video_every_n_cues":        4,
  "max_consecutive_same_scene": 3,
  "crossfade_duration_seconds": 0.5,
  "j_cut_offset_seconds":       1.5
}
```

**`thumbnail`** — Full thumbnail style guide:
```json
{
  "dimensions":        "1280x720",
  "hero_visual":       { "subject", "composition", "style", "lighting", "negative" },
  "text_overlay":      { "position", "style", "color_primary", "approved_openers", "never_use" },
  "branding":          { "channel_name", "position", "style", "color" },
  "variants_per_episode": 3,
  "variant_types":     ["evidence", "site", "atmospheric"]
}
```

**`pinned_clips`** — Channel intro and other fixed assets:
```json
{
  "id":               "channel_intro",
  "trigger_phrases":  ["welcome to ruins untold"],
  "match":            "contains",
  "asset_type":       "video",
  "asset_path":       "/path/to/your/intro.mp4",
  "duration_seconds": 6
}
```
Any cue whose narration contains a trigger phrase will substitute the pinned asset instead of generating a new prompt.

**`transcription`** — Whisper-cpp config used by the post-processing step.

---

## n8n Workflow Map

```
Manual Trigger
    │
    ▼
Read Ruins Untold Ideas     ← Google Sheets — reads A1:H11 (10 ideas)
    │
    ▼
Aggregate Topics            ← Code — builds numbered list + stashes row data
    │
    ▼
Select Episode Topic        ← Wait/Form — shows topic list, user picks 1–10 + VOICE_ID
    │
    ▼
Look Up Selected Row        ← Code — maps selection → full row (TOPIC, ANGLE, etc.)
    │
    ▼
Set Project Variables       ← projectSlug, projectDir, all episode fields
    │
    ▼
Create Project Directories  ← mkdir audio/ images/ videos/ scripts/ music/ sfx/
    │
    ▼
Generate Script — Claude    ← claude-opus-4-5, 16k tokens, full channel brief
    │
    ▼
Parse Script Response
    │
    ▼
Save Script to File
    │
    ▼
┌─ Script Review & Approval ─────────────────────────────── [GATE 1] ─┐
│  Approve → Generate Voiceover                                        │
│  Revise  → Revise Script — Claude → loop back                       │
└─────────────────────────────────────────────────────────────────────┘
    │
    ▼
Generate Voiceover — ElevenLabs
    │
    ▼
Save Voiceover File
    │
    ▼
┌─ Voiceover Review & Approval ──────────────────────────── [GATE 2] ─┐
│  Approve → Analyze Media Placement                                   │
│  Revise  → [flag for re-record]                                     │
└─────────────────────────────────────────────────────────────────────┘
    │
    ▼
Analyze Media Placement — Claude
    │
    ▼
Generate Asset Prompts — Claude
    │
    ▼
Parse Asset Prompts → Save Prompts File
    │
    ├── Expand Image Prompts → Write Image Prompts XLSX → Save
    ├── Expand Video Prompts → Write Video Prompts XLSX → Save
    ├── Expand Music Prompts → Generate Music (ElevenLabs) → Save
    └── Expand SFX Prompts  → Generate SFX (ElevenLabs)  → Save
                │
                ▼
        Wait — Manual Image & Video Generation
        [generate images/videos in external tools]
                │
                ▼
        All Assets Complete (Merge)
                │
                ▼
        Build Asset Manifest
                │
                ▼
┌─ Assets Review & Final Approval ───────────────────────── [GATE 3] ─┐
│  Approve → Generate FFmpeg Assembly Script                           │
│  Reject  → [flag for re-generation]                                 │
└─────────────────────────────────────────────────────────────────────┘
    │
    ▼
Generate FFmpeg Assembly Script
    │
    ▼
Write Assembly Script
    │
    ▼
Assemble Final Video — FFmpeg
    │
    ▼
Production Complete
```

---

## Project Directory Structure

Each episode gets its own directory. The generator and assembler expect this layout:

```
{projectSlug}/
├── audio/
│   └── voiceover.mp3
├── images/
│   ├── image_0001.png
│   └── … image_0168.png
├── videos/
│   ├── video_0001.mp4
│   └── … video_0056.mp4
├── music/
│   └── music_01.mp3  …  music_07.mp3
├── sfx/
│   └── sfx_01.mp3    …  sfx_09.mp3
└── scripts/
    ├── voiceover_transcript.srt   ← Whisper output (you provide)
    ├── timed_transcript.txt       ← generator writes
    ├── asset_prompts.json         ← generator writes
    ├── image_prompts.xlsx         ← generator writes
    ├── video_prompts.xlsx         ← generator writes
    ├── music_prompts.xlsx         ← generator writes
    ├── sfx_prompts.xlsx           ← generator writes
    ├── drift_check.xlsx           ← generator writes
    ├── thumbnail_prompts.xlsx     ← generator writes
    ├── media_placement.json       ← generator writes
    └── assemble.sh                ← generator writes
```

---

## Customizing for a New Episode

### Writing PROMPT_LIST

The most important manual step. `gen_asset_prompts.py` contains a `PROMPT_LIST` — 224 `(description, mood)` tuples, one per 7-second visual cue. These are written by hand from the timed transcript, not AI-generated.

Each tuple maps to what the narrator is saying at `cue × 7` seconds. The J-cut offset shifts the effective lookup back 1.5 seconds, so write the description for the image the viewer *sees*, not the exact words they're hearing.

Example pattern:
```python
# cue 4 — 28s — VIDEO — narrator says "welcome to ruins untold"
# ← pinned clip fires here (channel_intro), no prompt needed

# cue 8 — 56s — "the 1868 Smithsonian Annual Report documents..."
("Close-up of the 1868 Smithsonian Annual Report cover — "
 "gold-stamped institutional seal, cloth-bound, deep ochre, "
 "archive desk, period typography", "archival, methodical"),

# cue 12 — 84s — "...measurements that don't match the conclusion"
("Push into handwritten field notation pages — "
 "anomalous measurement figures circled in pencil, "
 "1870s field report paper, foxed edges", "investigative, unsettling"),
```

Aim for: **what is visible** + **cinematic direction** + **period/texture detail**.

After writing, run the generator and review `drift_check.xlsx` before generating any media.

---

## Voiceover Volume

The assembler automatically reduces voiceover volume at `10:18` (618 seconds):

```
Full volume (1.0×) → 0:00 to 10:17
Half volume (0.5×, −6 dB) → 10:18 to end
```

This is hardcoded for the current episode. For a different episode, edit the `618` value in the `assemble.sh` generation section of `gen_asset_prompts.py` (STEP 8) to match your desired timestamp in seconds.

---

## Connecting the Full Pipeline

This workflow is the third stage in the Ruins Untold system:

```
1.  RU_ideas skill           → generates ideas (Claude Code)
        │
        ▼
2.  Catalog workflow         → deduplicates + writes to Google Sheet
        │
        ▼
3.  Production pipeline      ← you are here
        │  picks "In Progress" rows from the sheet
        ▼
    Final video
```

For the full end-to-end flow:
1. Run `RU_ideas` in Claude Code to generate 10 ideas
2. The [Catalog workflow](../catalog/) writes net-new ideas to `Ruins_Untold_Ideas`
3. In the sheet, change a row's STATUS from `New` → `In Progress`
4. Trigger this production workflow — it reads the first 10 rows and lets you pick

---

## Related

| File/Folder | Description |
|---|---|
| [`../RU_ideas/`](../RU_ideas/) | Claude Code skill — generates video ideas in the RU format |
| [`../catalog/`](../catalog/) | n8n workflow — deduplicates and writes ideas to Google Sheets |
| [`../ru-thumbnail/`](../ru-thumbnail/) | Claude Code skill — generates NB2 thumbnail prompts on demand |
| [`../ruins_untold_script_node.md`](../ruins_untold_script_node.md) | The full scriptwriter system prompt used in node-04 |
