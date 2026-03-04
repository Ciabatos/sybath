# AGENTS.md

## Project: Sybath

Medieval/fantasy multiplayer turn-based game with real-time elements.

## Tech Stack

- **Framework**: Next.js 16+ (App Router)
- **Language**: TypeScript
- **Styling**: CSS Modules (per-component)
- **State**: Jotai, SWR
- **Icons**: `lucide-react`
- **UI Primitives**: Radix UI (`components/ui/**`)

## Project Structure

```
sybath/
├── app/                        # Next.js App Router pages
├── components/
│   ├── ui/                     # Reusable primitives (Button, Dialog, etc.)
│   └── NewComponents/          # New components go here by default
```

## Component Rules

- Every component file: `ComponentName.tsx` + `ComponentName.module.css` in `styles/` subfolder
- `"use client"` only when component uses browser APIs, event handlers, or hooks
- No Tailwind utility chains in JSX — use semantic CSS class names (`.panel`, `.header`, `.row`)
- Hook calls stay inside the component that owns them — don't scatter effects

## Visual Style

All major UI windows must look like in-game panels (Crusader Kings / Europa Universalis feel):

- Font: **Cinzel** for titles, system serif for body
- Colors: `#2b1810` (dark brown), `#5a4022` (brown), `#d4a574` / `#c89a4a` (gold), `#e6c998` (cream bg)
- Framed container with visible title bar, inner scroll area, subtle shadows
- Parchment / metallic texture aesthetic

Reference existing styles in `components/**/styles/` for consistency.

## Hook-based UI Rules

When building UI from a hook:

- Consume ONLY the provided hook — do not fetch data, mock the hook, or add alternative sources
- Display all data the hook returns
- You MAY add UI-only presentation layer: labels, icons, badges, empty states, grouping, visual rarity colors
- All functions inside components use traditional `function` syntax (not arrow functions at module level)
