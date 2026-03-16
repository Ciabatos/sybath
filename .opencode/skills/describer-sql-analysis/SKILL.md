---
name: describer-hook-analysis
description: |
  Scans existing functions in the project and extracts design,
  structure, and architectural patterns. The result is used as context.

  Use when:
  "scan components", "analyze UI components", "extract UI patterns",
  "prepare context for component generation".
---

Input: Dependencies list from Skill 1 Goal: For each dependency, trace:

If it’s a fetcher → show what endpoint it calls, what parameters it uses, how it populates atoms

If it’s an atom → show what it stores and its type

If it’s another hook → recursively analyze (like Skill 1)

Output: Detailed explanation of how each dependency works and how it connects to the database (game-db) or other data
sources.
