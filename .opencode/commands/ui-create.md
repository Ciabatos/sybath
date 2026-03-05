Build a UI component for the Sybath game. Focus on rendering things not functions for interactions ! ONLY CREATE TWO
FILES DONT DO ANY MORE VERIFICATIONS ETC

DONT USE LINUX BASH COMMANDS ITS ALL IN PROJECT

## Step 1 — Read project styles first

Before writing any code, read ALL existing CSS modules and UI components:

- Read files in path @components/ look only in this directory for THE TASK !
- The directory @components/ui is extremely large. Reading it will crash the context window.
- Use what you find as the visual reference. Match naming conventions, color usage, and class structure exactly. When
  you are ready go to step 2

## Step 2 — Think before coding

Before writing any file, briefly plan:

- What sections does this window need? (header, list, sidebar, footer, etc.)
- What data from the hook maps to which section?
- What CSS classes will be needed?

## Inputs

- **Component name**: $1
- **UI purpose**: $2
- **Layout & behavior**: $3
- **Hook file path**: $4
- **Mock data allowed**: $5

## Only files to create or edit !

- @components/NewComponents/$1.tsx
- @components/NewComponents/styles/$1.module.css

- Do NOT run shell commands to create directories. Just write the files directly — the editor creates directories
- Automatically. Skip any `mkdir` or `cd` steps. Folders NewComponents and styles exists
- Do not look for hooks if not provided in **Hook file path**

---

## Project context

Medieval/fantasy strategic/rpg turn-based game on world map grid with coordinates x and y. Next.js 16 App Router ·
TypeScript · CSS Modules · Jotai · SWR · lucide-react · Radix UI.

**Colors:** `#2b1810` dark brown · `#5a4022` brown · `#d4a574`/`#c89a4a` gold · `#e6c998` cream  
**Fonts:** `Cinzel` for titles · system serif for body  
**Aesthetic:** CK3/EU4 panel — parchment, metallic accents, framed container

**Hard rules:**

- Use type instead of interface
- `"use client"` at top
- `useState` — top of component body, UI state only (tabs, toggles, open/close)
- Hook call — inside component body only
- Internal functions — traditional `function` syntax only
- Semantic class names only (`.panel`, `.row`, `.badge`) no Tailwind
- Use `@components/ui/**` for Button, Dialog, Tooltip, etc.
- Focus on **rendering only** stub all handlers, do not implement business logic.
- Represent numeric stats as icon + value pairs, never plain text labels alone
- Use colored dot/pip elements for levels (1–5 stars, health bars, morale pips)
- Never conditionally hide actions — show grayed

If $5 is yes:

- Define ONE flat MOCK object. No deep nesting — max 2 levels inside component body
- Define MOCK **inside the component function body**, after useState declarations.
- MOCK data — read directly in JSX with `MOCK.value`, never via `setState(MOCK.something)`
- Never copy MOCK values into state — if it comes from the hook/MOCK, render it directly

---

## CSS Module rules (`$1.module.css`)

- Background: `#2b1810` for window, `#e6c998` / `#f0d9a0` for content areas
- Borders: `1px–2px solid #c89a4a` with `box-shadow` for depth
- Title: `font-family: 'Cinzel', serif` · color `#d4a574`
- Hover states: gold highlight `#d4a574` on interactive rows
- Parchment feel: slight `background-image` texture or gradient where appropriate
- Reference existing styles in `@components/**/styles/` for exact conventions

---

## Component rules (`$1.tsx`)

```tsx
"use client"

import styles from "./styles/$1.module.css"
import { useState } from "react"
import { Button } from "@/components/ui/button"
import { SomeIconFromListBelow } from "lucide-react"

export default function $1() {
  // 1. useState — always at top of component body
  // 2. hook call — always inside component body

  // ─── MOCK (delete when real hook is connected) ────────────────────────────────
  const MOCK = {
    // ALL test data as one object
  }
  // ─────────────────────────────────────────────────────────────────────────────

  // 3. derived values

  // internal functions — ALWAYS traditional function syntax
  function handleSomeAction(params: { id: string }) {
    // ...
  }

  return (
    <div className={styles.window}>
      <div className={styles.titleBar}>
        <h2 className={styles.title}>{MOCK.title}</h2>
      </div>
      <div className={styles.content}>{/* main content */}</div>
    </div>
  )
}
```

## Lucide icons — Import only from this list. If the icon you need is not here, use the closest alternative that is. Never guess or invent a name.

- correct import { Sword, Shield, Coins } from "lucide-react"

Weapons: `Sword Swords Shield Axe Crosshair Target Skull BowArrow`  
Characters: `User Users Crown Trophy UserCheck UserX UserPlus`  
Buildings: `Castle Church Building Building2 House Landmark Flag`  
Fire/light: `Flame Sun Moon Sunrise Sunset Lamp`  
Resources: `Heart Coins Gem Diamond Backpack Package Barrel Vault`  
Tools: `Binoculars Anvil Amphora Pickaxe Hammer Shovel Wrench Anvil`  
Food: `Apple Wheat WheatOff Beef FlaskConical FlaskRound Droplets`  
Magic: `Biohazard Sparkles Zap WandSparkles Wand2 BookOpen ScrollText Eye Ghost`  
Map: `Map MapPin Compass Globe Mountain Trees Footprints Telescope Signpost`  
Camp: `Tent Bed Wind CloudRain Snowflake`  
UI: `X Check Shrink Info AlertTriangle Clock Hourglass ChevronDown ChevronUp`  
Ships/Travel: `Sailboat Anchor Ship ShipWheel`  
Strategy: `BrickWall BrickWallShield BrickWallFire ChessKing ChessRook ChessQueen Dice1 Dice6 Dices` Others:
`Thermometer`

## Rendering note

This component will be mounted inside one of the panel wrappers at `@components/panels/**`.  
Do not add page-level layout — the panel provides positioning and z-index. "Focus on rendering" only UI and mock data,
funcionality leave for manual user correction.

## JSX conditionals — splitting rules

Never use ternary (? :) in JSX when either branch exceeds 3 lines.Instead:

1. Extract each branch into a named sub-component with early return
2. Sub-components live in the same file
