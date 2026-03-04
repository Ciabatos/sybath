---
description: Build a Next.js game-style in-game window UI component from a hook.
---

read .opencode\AGENTS.md first here is the text of it !`cat .opencode/AGENTS.md`

Build a UI component for the Sybath game.

## Inputs

- **Component name**: $1
- **UI purpose** (what does this window represent): $2
- **Layout & behavior** (describe interactions, sections, filters, etc.): $3
- **Hook file path**: $4
- **Allow UI-only mock/presentation data** (yes/no): $5

## Output requirements

### Files to create

1. `/components/NewComponents/$1.tsx` — React component
2. `/components/NewComponents/styles/$1.module.css` — CSS Module

### Component structure tsx

```
- Hook calls must be INSIDE function component body
- useState declarations must be INSIDE component body (START of component)
- All internal functions use traditional function syntax
- try to wrap into object before passing parameters to function

import styles from "./styles/$1.module.css"
// import hook from "$4"
// import { Button, Dialog, etc. } from "@/components/ui/..."

Example of UI :
export default function $1() {
  // HOOKS: call hooks INSIDE component

  // useState: DECLARED INSIDE component, at START

  return (

    <div className={styles.window}>
      <div className={styles.titleBar}>
        <h2 className={styles.title}>WINDOW TITLE</h2>
      </div>
      <div className={styles.content}>
        {/* main content */}
      </div>
    </div>
  )
}
```

### CSS Module structure

Follow the visual conventions from `components/**/styles/**`. Color palette and font from .opencode\AGENTS.md

## Rules

- Consume ONLY the hook from `$4` — no direct fetch calls
- No Tailwind utility chains in JSX
- Use components from `components/ui/**` for buttons, dialogs, tooltips
- Traditional `function` syntax for all internal functions
- Window must visually resemble a CK3/EU4 in-game panel
- useState declarations MUST be inside component function body, never at file/module level
- Hook calls stay inside component — no effects at module level

## Mocking

- Always -mock data in the component UI so i can test it and delete later

##Rendering

- Component will be rendered in one of the Panels components that are here in this location `components\panels\**`

## Examples

you can create UI based on: !`find components -type f -exec cat {} +`
