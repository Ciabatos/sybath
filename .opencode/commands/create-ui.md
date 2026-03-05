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

> Do NOT run shell commands to create directories. Just write the files directly — the editor creates directories
> automatically. Skip any `mkdir` or `cd` steps. Folders NewComponents and styles exists

---

## Component rules (`$1.tsx`)

```tsx
"use client"

import styles from "./styles/$1.module.css"
// import { useYourHook } from "$4"
// import { useState } from "react"
// import { Button } from "@/components/ui/button"
// import { SomeIcon } from "lucide-react"

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

**Hard rules:**

- `useState` — inside component body, at the very top
- `useState` — ONLY for UI interaction state (tabs, toggles, open/close)
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

When $5 is **yes** or `$4` is "none":

- Put ALL test data in the single `MOCK` object
- Use `MOCK.*` directly in JSX
- Comment every mock value with `// mock`
- Define ONE flat MOCK object. No deep nesting — max 2 levels.
- Define MOCK **inside the component function body**, after useState declarations.
- MOCK data — read directly in JSX with `MOCK.value`, never via `setState(MOCK.something)`
- Never copy MOCK values into state — if it comes from the hook/MOCK, render it directly

---

## Rendering note

This component will be mounted inside one of the panel wrappers at `components/panels/**`.  
Do not add page-level layout — the panel provides positioning and z-index. "Focus on rendering" only UI and mock data,
funcionality leave for manual user correction.

## Lucide React — verified icons only

Import only from this list. If the icon you need is not here, use the closest alternative that is. Never guess or invent
a name.

Sword, Shield, Helmet, Bow, Axe, Spear

User, UserCheck, UserX, UserPlus, UserMinus

Hand, HandMetal, HandCoins

Castle, Church, House, Tower, Fort, Barracks, Building ,Building2

Fire, Flame, BrickWall, BrickWallShield, Fence, Lamp

Coin, Coins, Chest, Handbag, Backpack, Gem, Diamond

Axe, Pickaxe, Hammer, Shovel

Apple, Meat, Potion, FlaskConical, FlaskRound

Sparkles, Star, Lightning, Fire, Zap, Moon, Sun, CrescentMoon

Hexagon, Circle, Triangle

MagicWand, SpellBook, Book, BookOpen, BookHeart

Map, Compass, Globe, ArrowUp, ArrowDown, ArrowLeft, ArrowRight

Flag, FlagTriangleLeft, FlagTriangleRight, Crown

Check, X, AlertCircle, Info, Loader

AlertCircle, Bed, Clock, Flame, Moon, Sunrise, Tent, User

| Category                   | Verified import names                                                                                                                                                                             |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Weapons / combat**       | `Sword`, `Swords`, `Shield`, `Axe`, `BowArrow`, `Crosshair`, `Target`, `Skull`                                                                                                                    |
| **Characters**             | `User`, `Users`, `UserRound`, `UserCheck`, `UserX`, `UserPlus`, `UserMinus`, `Crown`, `Trophy`                                                                                                    |
| **Buildings / structures** | `Castle`, `Church`, `Building`, `Building2`, `House`, `Tower`, `Landmark`, `Warehouse`, `Flag`, `FlagTriangleLeft`, `FlagTriangleRight`                                                           |
| **Fire / light**           | `Flame`, `FlameKindling`, `Sun`, `Sunrise`, `Sunset`, `Moon`, `MoonStar`, `Flashlight`, `Lamp`                                                                                                    |
| **Resources / wealth**     | `Coins`, `Gem`, `Diamond`, `Backpack`, `Package`, `Barrel`, `Vault`, `PiggyBank`, `Banknote`                                                                                                      |
| **Tools / crafting**       | `Pickaxe`, `Hammer`, `Shovel`, `Wrench`, `Anvil`, `Drill`                                                                                                                                         |
| **Food / survival**        | `Apple`, `Wheat`, `Beef`, `Utensils`, `UtensilsCrossed`, `FlaskConical`, `FlaskRound`, `Droplets`                                                                                                 |
| **Magic / mystic**         | `Sparkles`, `Sparkle`, `Star`, `Stars`, `Zap`, `WandSparkles`, `Wand2`, `BookOpen`, `BookHeart`, `Scroll`, `ScrollText`, `Eye`, `Ghost`, `Hexagon`                                                |
| **Map / exploration**      | `Map`, `MapPin`, `MapPinned`, `Compass`, `Globe`, `Mountain`, `MountainSnow`, `Trees`, `TreePine`, `TreeDeciduous`, `Footprints`, `Telescope`, `Binoculars`                                       |
| **Camp / rest**            | `Tent`, `TentTree`, `Bed`, `BedDouble`, `Wind`, `CloudRain`, `Snowflake`, `Thermometer`                                                                                                           |
| **Interface / status**     | `X`, `Check`, `Info`, `AlertTriangle`, `AlertCircle`, `Clock`, `Calendar`, `Hourglass`, `Timer`, `ChevronUp`, `ChevronDown`, `ChevronLeft`, `ChevronRight`                                        |
| **Ships / travel**         | `Sailboat`, `Anchor`, `Ship`, `ShipWheel`                                                                                                                                                         |
| **Strategy / board**       | `BrickWall`, `BrickWallShield`, `BrickWallFire`, `ChessKing`, `ChessQueen`, `ChessRook`, `ChessKnight`, `ChessBishop`, `ChessPawn`, `Dice1`, `Dice2`, `Dice3`, `Dice4`, `Dice5`, `Dice6`, `Dices` |

```tsx
// ✅ correct
import { Sword, Shield, Coins } from "lucide-react"
```
