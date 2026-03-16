---
name: describer-hook-analysis
description: |
  Scans existing functions in the project and extracts design,
  structure, and architectural patterns. The result is used as context.

  Use when:
  "scan components", "analyze UI components", "extract UI patterns",
  "prepare context for component generation".
---

Input: Hook name (string) Goal: Find out:

Where the hook is defined in the codebase

What its internal logic is (fetching, processing, combining atoms)

Which other hooks or functions it calls (e.g., fetchers, useAtomValue)

What atoms or state it depends on

Output: List of dependencies and a high-level description of the hook.

Example logic:

Input: useMapHandling

Step 1: Locate useMapHandling.ts Step 2: Analyze code - Calls useFetchKnownMapTiles → fetch + sets knownMapTilesAtom -
Calls useAtomValue for various atoms (citiesAtom, districtsAtom, etc.) - Combines data per tile into TMapTile[] Step 3:
Record all fetch hooks and atoms it depends on Step 4: Generate dependency list Output: { hookDescription: "Combines all
map-related data per tile and returns map info...", dependencies: ["useFetchKnownMapTiles", "knownMapTilesAtom",
"citiesAtom", "districtsAtom", ...] }
