# RU_ideas

**Skill for:** The Ruins Untold YouTube Channel  
**Type:** Content Ideation  
**Output:** Structured video ideas in a fixed 7-field format

---

## What It Does

Generates fully structured video ideas for **The Ruins Untold** — a faceless YouTube channel covering ancient mysteries, forbidden archaeology, and alternative history.

Every idea is evidence-first and includes a named mainstream antagonist, specific dated sources, an unanswered question, and a tone calibrated for the channel's investigative voice.

---

## Usage

| Prompt | Output |
|--------|--------|
| `Give me ideas for the channel` | 10 ideas, mixed topics |
| `RU_ideas Egypt` | 10 ideas, Egypt-specific |
| `RU_ideas underwater sites` | 10 ideas on that topic |
| `RU_ideas 3` | Exactly 3 ideas |
| `Give me one idea — strong cover-up angle, tone 8` | 1 idea, TONE_DIAL: 8 |

---

## Output Format

Every idea uses this exact structure:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IDEA 01
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOPIC:           Short punchy title (5–10 words)

ANGLE:           3–5 sentences. Opens with the mainstream consensus
                 as settled fact. Cracks it with the physical anomaly.
                 Names the gatekeeper. Ends on the unanswered question.

KEY_EVIDENCE:    Minimum 4 items — paper title + date, artifact +
                 location, document + year, institution + action.
                 Always specific. Never vague.

KEY_RESEARCHERS: Named individuals with roles. Always includes at
                 least one antagonist, labeled as such.

RELATED_VIDEO:   Prior Ruins Untold episode this connects to,
                 or "none yet"

HOOK_STYLE:      question / statement / contradiction / anomaly /
                 revelation

TONE_DIAL:       Integer 1–10. Sweet spot: 6–7. Max default: 8.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Sample Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IDEA 01
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOPIC:           The Sphinx Is 12,000 Years Old — Geologists Can Prove It

ANGLE:           The official story is that the Sphinx was carved around
                 2500 BCE under Pharaoh Khafre. But geologist Robert Schoch's
                 1991 peer-reviewed analysis showed the Sphinx enclosure walls
                 bear deep vertical rainfall erosion requiring thousands of
                 years of heavy precipitation that ended no later than 9000
                 BCE. Zahi Hawass publicly ridiculed Schoch at the 1992 AAAS
                 conference and blocked all independent geological access ever
                 since. If the Sphinx predates the pyramids by millennia, who
                 built it — and what else are they hiding beneath it?

KEY_EVIDENCE:    Schoch 1991 JARCE rainfall erosion analysis, Dobecki and
                 Schoch 1992 seismic survey (anomalous chambers beneath left
                 paw), Dream Stele of Thutmose IV 1400 BCE (describes Sphinx
                 as already ancient), Colin Reader 2001 independent geological
                 corroboration, 1992 AAAS conference transcript (Hawass denial
                 on record)

KEY_RESEARCHERS: Robert Schoch (Boston University geologist, primary
                 researcher), Zahi Hawass (Egyptian Supreme Council of
                 Antiquities — antagonist, blocked all independent access),
                 John Anthony West (brought Schoch to Egypt),
                 Colin Reader (independent corroboration)

RELATED_VIDEO:   none yet

HOOK_STYLE:      contradiction

TONE_DIAL:       6
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Topic Categories

| Category | Examples |
|----------|---------|
| Suppressed Sites | Giza, Puma Punku, Göbekli Tepe, Sacsayhuamán, Nan Madol, Baalbek |
| Forbidden Geology | Water erosion, machined stone tolerances, vitrified forts, underground cities |
| Mainstream Cover-ups | Smithsonian, academic journals, governments suppressing evidence |
| Lost Civilizations | Pre-flood builders, pre-Ice Age cultures, Atlantis, Mu |
| Out-of-Place Artifacts | Baghdad Battery, Antikythera Mechanism, Dendera reliefs, crystal skulls |
| Ancient Technology | Unknown construction methods, precision machining, acoustic theory |
| Mythological Evidence | Flood myths, sky gods, cross-cultural legends as eyewitness accounts |
| Forbidden Texts & Maps | Piri Reis, Library of Alexandria, hidden scrolls, cuneiform tablets |
| Archaeological Whistleblowers | Researchers fired or defunded for anomalous findings |

---

## Tone Dial Reference

| Value | Meaning |
|-------|---------|
| 5 | Straight investigative — evidence-led, minimal framing |
| 6 | Conspiratorial edge — named gatekeepers, questions mainstream |
| 7 | Strong suppression framing — institution vs. evidence narrative |
| 8 | Cover-up intensity — "they knew and buried it" framing |
| 9–10 | Extreme — only when explicitly instructed |

**Default sweet spot: 6–7**

---

## What Makes a Strong Idea

Every idea must pass all five:

1. **Mainstream consensus to crack** — the official story in one sentence
2. **Concrete physical anomaly** — measurable, photographable, documentable
3. **Named gatekeeper or antagonist** — the institution or person blocking the evidence
4. **Unanswered question** — one that cannot be dismissed
5. **Emotional stake** — suppression, betrayal, awe, or vindication

---

## Eval Results

Tested across 3 iterations against 3 eval prompts (default 10, topic filter, high-tone single).

| Iteration | with_skill pass rate | Key fix |
|-----------|---------------------|---------|
| 1 | 0.25 | Format template not followed |
| 2 | 1.0 | Inline template + count rule added |
| 3 | 1.0 | Tone ceiling lowered to 6–7 default |

**Final pass rate: 100% across all evals.**
