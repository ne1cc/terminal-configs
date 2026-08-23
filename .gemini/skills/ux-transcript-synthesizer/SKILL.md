---
name: ux-transcript-synthesizer
description: Parses raw user interviews, session recordings, and usability logs into clustered Jobs-To-Be-Done (JTBD) frameworks, pain-point hierarchies, and friction maps.
---

# UX Transcript & Feedback Synthesizer

Transform unstructured user feedback, transcripts, and usability logs into structured, actionable product requirements.

## Core Processing Pipeline

1. **Extraction:** Ingest raw interview text, user bug reports, or support tickets.
2. **JTBD Clustering:** Map findings into the Jobs-To-Be-Done framework:
   - *When I [context], I want to [motivation], so that I can [desired outcome].*
3. **Pain-Point Hierarchy:** Rank frictions by frequency and severity:
   - **P0 (Blocker):** Causes drop-off or task abandonment.
   - **P1 (Friction):** Causes confusion or excessive cognitive load.
   - **P2 (Papercut):** Aesthetic or minor efficiency gap.
4. **Friction Map:** Trace the user journey step-by-step, pinpointing where reality diverged from expectations.
