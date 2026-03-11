# OpenCode Prompt — Generate UI Component

## Your Role

Senior Frontend Engineer specialized in **Next.js 16**, **TypeScript** for medieval strategy game interfaces UI.

---

# Task

Generate **ONE React component file** that renders a UI panel.

The component must follow the **existing project design system** and focus **only on rendering UI**.

---

# Inputs

| Param | Description       |
| ----- | ----------------- |
| $1    | Component name    |
| $2    | UI purpose        |
| $3    | Layout & behavior |

---

# File To Generate

@components/NewComponents/$1.tsx

---

# STRICT OUTPUT RULES

Allowed output:

- **Raw TypeScript code only**

Forbidden output:

- Markdown
- Code fences
- Explanations
- File paths
- Multiple files
- Shell commands

If any forbidden output appears → **regenerate**.

---

# Directory Rules

You may ONLY reference components from:

@components/\*

Strictly avoid reading or referencing any other directories.

---

# Tech Stack

- Next.js 16 App Router
- TypeScript
- lucide-react

---

# Visual Style

Medieval / CK3 style interface.

---

# Hard UI Rules

Focus on **rendering only**.

Do NOT implement gameplay logic.

Handlers must be **stub functions**.

Actions must **never be hidden**  
Disabled actions must appear **greyed out**.

Numeric stats must appear as:

Icon + value

Example:

Heart 120 Coins 340

Never render numeric values without an icon.

Never use Tailwind classes.

---

# TypeScript Rules

`"use client"` must be the first line.

Use:

type

Never use:

interface

---

# useState Rules

useState declarations must appear **at the top of the component body**.

Allowed only for UI state:

- tabs
- toggles
- open/close

---

# Mock Data Rules

Create one object:

const MOCK = {}

Rules:

- only **one mock object**
- maximum nesting depth **2**
- defined **after useState**
- never copied into state
- read **directly inside JSX**

Example:

MOCK.gold MOCK.army.size

Never use `setState` with MOCK data.

---

# Icon Rules

Only import icons from this list:

Weapons  
Sword Swords Shield Axe Crosshair Target Skull BowArrow

Characters  
User Users Crown Trophy UserCheck UserX UserPlus

Buildings  
Castle Church Building Building2 House Landmark Flag

Fire/light  
Flame Sun Moon Sunrise Sunset Lamp

Resources  
Heart Coins Gem Diamond Backpack Package Barrel Vault

Tools  
Binoculars Anvil Amphora Pickaxe Hammer Shovel Wrench

Food  
Apple Wheat WheatOff Beef FlaskConical FlaskRound Droplets

Magic  
Biohazard Sparkles Zap WandSparkles Wand2 BookOpen ScrollText Eye Ghost

Map  
Map MapPin Compass Globe Mountain Trees Footprints Telescope Signpost

Camp  
Tent Bed Wind CloudRain Snowflake

UI  
X Check Shrink Info AlertTriangle Clock Hourglass ChevronDown ChevronUp

Ships  
Sailboat Anchor Ship ShipWheel

Strategy  
BrickWall BrickWallShield BrickWallFire ChessKing ChessRook ChessQueen Dice1 Dice6 Dices

Other  
Thermometer

---

# Component Structure

The component must follow this structure:

"use client"

import styles from "./styles/$1.module.css" import { useState } from "react" import { Button } from
"@/components/ui/button" import { ICONS } from "lucide-react"

export default function $1() {

// UI state

// MOCK data

// derived values

function handleAction() {}

return (

<div className={styles.panel}>
  <div className={styles.titleBar}>
    <div className={styles.title}></div>
  </div>

  <div className={styles.content}>

  </div>
</div>
)
}

---

# JSX Rules

Never use long ternary expressions inside JSX.

If conditional rendering exceeds **3 lines**, extract a **subcomponent inside the same file**.

---

# Context

This component will be rendered inside a panel wrapper located at:

@components/panels/\*\*

Do NOT add layout logic.

Focus only on the **panel UI rendering**.

---

# Final Validation

Before returning output verify:

- only one file generated
- only TypeScript code returned
- no markdown
- no explanations

If any rule is violated → **regenerate**.
