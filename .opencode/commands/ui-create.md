# Sybath — In-Game UI Window Component

## Inputs

- **Component name**: $1
- **UI purpose**: $2
- **Layout & behavior**: $3
- **Hook file path**: $4
- **Mock data allowed**: $5

## Files to create

- `components/NewComponents/$1.tsx`
- `components/NewComponents/styles/$1.module.css`

Do NOT run shell commands. Write files directly.

---

## Project context

Medieval/fantasy strategic/rpg turn-based game on world map grid with coordinates x and y. Next.js 16 App Router ·
TypeScript · CSS Modules · Jotai · SWR · lucide-react · Radix UI.

**Colors:** `#2b1810` dark brown · `#5a4022` brown · `#d4a574`/`#c89a4a` gold · `#e6c998` cream  
**Fonts:** `Cinzel` for titles · system serif for body  
**Aesthetic:** CK3/EU4 panel — parchment, metallic accents, framed container

## Step 1 — Read project styles first

Before writing any code, read ALL existing CSS modules and UI components:

- Read every file in `components/`

Use what you find as the visual reference. Learn naming conventions, color usage, and class structure.

## Step 2 — Think before coding

Before writing any file, briefly plan:

- What sections does this window need? (header, list, sidebar, footer, etc.)
- What data from the hook maps to which section? - if **Hook file path** provided, else take data from Mock
- What CSS classes will be needed?

## Component rules

- Use type not interface for all prop definitions
- `"use client"` at top
- `useState` — top of component body, UI state only (tabs, toggles, open/close)
- Hook call — inside component body only
- Internal functions — traditional `function` syntax only
- Semantic class names only (`.panel`, `.row`, `.badge`) no Tailwind
- Use `components/ui/**` for Button, Dialog, Tooltip, etc.
- Focus on **rendering only** stub all handlers, do not implement business logic, this component is PRESENTATIONAL ONLY.
- Represent numeric stats as icon + value pairs, never plain text labels alone
- Use colored dot/pip elements for levels (1–5 stars, health bars, morale pips)
- Wrap every stat, badge, and icon in Tooltip from components/ui/tooltip
- Tooltip content: Use short placeholder text if real logic is unknown.
- Action buttons render always — disable with disabled prop + Tooltip with placeholder "Unavailable" in mock
- Never conditionally hide actions based on permissions — show grayed with reason
- Numeric values that can change show delta: +12 / -5 in smaller text beside main value · delta 0 = do not render
  element at all
- Positive delta: color #4a7c4a green · Negative delta: color #7c2a2a red

If $5 is yes:

- One flat `MOCK` object inside component body (max 2 levels deep)
- Render `MOCK.*` directly in JSX — never copy into state

---

## CSS rules

- Window bg: `#2b1810` · content areas: `#e6c998` / `#f0d9a0`
- Borders: `1–2px solid #c89a4a` + `box-shadow`
- Titles: `font-family: 'Cinzel', serif` · color `#d4a574`
- Interactive rows: gold hover `#d4a574`
- Reference existing styles in `components/**/styles/`

---

## Component rules (`$1.tsx`)

```tsx
"use client"

import styles from "./styles/$1.module.css"
// import { useYourHook } from "$4"
// import { useState } from "react"
// import { Button } from "@/components/ui/button"
// import { SomeIconFromListBelow } from "lucide-react"

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

sub-components (if needed)
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

This component will be mounted inside one of the panel wrappers at `components/panels/**`.  
Do not add page-level layout — the panel provides positioning and z-index. "Focus on rendering" only UI and mock data,
funcionality leave for manual user correction.

## JSX conditionals — splitting rules

Never use ternary (? :) in JSX when either branch exceeds 3 lines.

Instead:

1. Extract each branch into a named sub-component with early return
2. Sub-components live in the same file, below the main component
3. Main component just renders as in this example: `<ExplorationStatus isExploring={isExploring} />`

When to use each pattern:

- 2 states, both long → two sub-components + early return
- 2 states, one is null → single sub-component + && in JSX
- 3+ states → one sub-component per state + if/else chain with early return, never lookup objects
- both branches ≤ 3 lines → ternary is fine

Sub-component rules:

- Props typed inline with type, no separate interface unless reused
- Traditional function syntax: `function ExplorationStatus(props: Props) {}`
- File-private — no export

Follow the instructions strictly.
