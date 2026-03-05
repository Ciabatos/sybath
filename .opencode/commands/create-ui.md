---
description: Build a Next.js game-style in-game window UI component from a hook.
---

## Step 1 — Read project styles first

Before writing any code, read ALL existing CSS modules and UI components:

- Read every file in `components/`

Use what you find as the visual reference. Match naming conventions, color usage, and class structure exactly.

## Step 2 — Think before coding

Before writing any file, briefly plan:

- What sections does this window need? (header, list, sidebar, footer, etc.)
- What data from the hook maps to which section?
- What CSS classes will be needed?

## Project context — Sybath

Medieval/fantasy multiplayer turn-based game with real-time elements.

|                   |                                          |
| ----------------- | ---------------------------------------- |
| **Framework**     | Next.js 16+ App Router                   |
| **Language**      | TypeScript                               |
| **Styling**       | CSS Modules (per-component, no Tailwind) |
| **State**         | Jotai, SWR                               |
| **Icons**         | lucide-react                             |
| **UI Primitives** | Radix UI — `components/ui/**`            |

**Colors:** `#2b1810` dark brown · `#5a4022` brown · `#d4a574` / `#c89a4a` gold · `#e6c998` cream bg  
**Fonts:** `Cinzel` for all titles · system serif for body text  
**Aesthetic:** CK3 / EU4 in-game panel — framed container, parchment texture, metallic accents, subtle shadows

---

## Inputs

- **Component name**: $1
- **UI purpose** (what does this window represent): $2
- **Layout & behavior** (sections, interactions, filters): $3
- **Hook file path**: $4
- **Allow UI-only mock/presentation data** (yes/no): $5

---

## Files to create

| File            | Path                                            |
| --------------- | ----------------------------------------------- |
| React component | `components/NewComponents/$1.tsx`               |
| CSS Module      | `components/NewComponents/styles/$1.module.css` |

---

## Component rules (`$1.tsx`)

```tsx
"use client"

import styles from "./styles/$1.module.css"
// import { useYourHook } from "$4"
// import { Button } from "@/components/ui/button"
// import { SomeIcon } from "lucide-react"

// ─── MOCK (delete when real hook is connected) ────────────────────────────────
const MOCK = {
  // ALL test data as one object
}
// ─────────────────────────────────────────────────────────────────────────────

export default function $1() {
  // 1. useState — always at top of component body
  // 2. hook call — always inside component body
  // 3. derived values

  // internal functions — ALWAYS traditional function syntax
  function handleSomeAction(params: { id: string }) {
    // ...
  }

  return {
    /* main content */
  }
}
```

**Hard rules:**

- `useState` — inside component body, at the very top
- Hook calls — inside component body only, never at module level
- Internal functions — traditional `function` syntax, never arrow functions at module level
- Params — wrap into object before passing: `handleAction({ id, type })` not `handleAction(id, type)`
- Focus on **rendering** — stub interaction handlers, do not implement business logic
- No Tailwind utility chains in JSX — semantic class names only (`.panel`, `.row`, `.badge`)
- Use `components/ui/**` for Button, Dialog, Tooltip, etc.
- Focus on **rendering only** — stub all handlers, do not implement business logic

---

## CSS Module rules (`$1.module.css`)

**Style conventions:**

- Background: `#2b1810` for window, `#e6c998` / `#f0d9a0` for content areas
- Borders: `1px–2px solid #c89a4a` with `box-shadow` for depth
- Title: `font-family: 'Cinzel', serif` · color `#d4a574`
- Hover states: gold highlight `#d4a574` on interactive rows
- Parchment feel: slight `background-image` texture or gradient where appropriate
- Reference existing styles in `components/**/styles/` for exact conventions

---

## Mocking

When `$6` is **yes** or `$4` is "none":

- Put ALL test data in the single `MOCK` object
- Use `MOCK.*` directly in JSX
- Comment every mock value with `// mock`

---

## Rendering note

This component will be mounted inside one of the panel wrappers at `components/panels/**`.  
Do not add page-level layout — the panel provides positioning and z-index. "Focus on rendering" only UI and mock data,
funcionality leave for manual user correction.
