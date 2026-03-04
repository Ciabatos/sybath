# AGENTS.md

## Project: Sybath - Medieval/Fantasy Multiplayer Turn Game with real time

## Overview

Sybath is a medieval/fantasy-themed game built with Next.js, React, TypeScript, and Tailwind CSS.

## Tech Stack

- Next.js
- **Frontend**: React (Vite)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Icons**: Lucide React
- **Architecture**: Component-based with type-safe state management
- SWR https://swr.vercel.app/
- Jotai https://jotai.org/

## Common Tasks for You

### UI built strictly from user-provided hooks

- The user will always describe in the prompt what the UI is supposed to represent and how it should behave (for
  example: inventory view, market window, price history view, equipment panel, etc.).
- Treat the user description as the functional UI specification.
- The user always provides a ready data hook (for example: a hook returning market items, or historical prices).
- Your task is to build ONLY the UI layer for that hook.

You MUST:

- NOT create or modify the hook logic.
- NOT fetch data directly.
- NOT introduce alternative data sources.
- ONLY consume the hook provided by the user.
- reflect the described purpose clearly in the visual structure (for example: inventory grid, market list with prices,
  historical chart, filters, etc.).
- follow the user’s UI intent when designing layout, components and interactions.

-All hooks and internal functions must use **traditional `function()` syntax**

You MAY:

- introduce additional UI-only data if it improves usability or visual clarity, such as:
  - section titles,
  - labels,
  - icons,
  - visual statuses,
  - empty-state placeholders,
  - grouping or categorization purely for presentation,
  - local mock or derived values used only for display (for example: visual rarity tiers, colors, badges).
  - mock data for it i will later replace it manually and add this into data fetcher for that component

The UI component must:

- display all relevant data returned by the hook,

Typical examples:

- a hook that returns all market items → build a full market window UI displaying those items,
- a hook that returns historical price data → build a historical price chart UI.
- a hook that returns inventory of player → build UI for player inventory.

---

### Visual style and layout (window-based UI)

- All major UI created from hooks should be presented as a window / panel view.
- The window layout must resemble strategy game UI windows (similar to Crusader Kings or Europa Universalis):
  - framed container,
  - visible header / title bar,
  - inner content area,
  - subtle borders, shadows and depth,
  - medieval / parchment / metallic feeling.

The goal is to make every hook-based UI look like an in-game window, not a generic web card.

---

### Styling

- Create consistent medieval-themed styles based on existing styles from all `styles` directories located anywhere
  inside the `components` tree (pattern: `components/**/styles/**`).
- Treat all existing `styles` folders as a shared visual reference and follow their conventions (naming, structure,
  effects, colors, shadows, etc.).

### Reusable UI components (Radix UI)

- Prefer using reusable UI components (e.g. Button, Dialog, etc.) from: `components/ui/**`.

## Project Structure

```
sybath/
  components/
    NewComponents/    # New components should be placed here if folder dont exists then create it
    Player/           # Player component and types
    Inventory/          # Inventory component and types
    Equipment/          # Equipment components and types
    PlayerGear/        # Player gear display component

```

## Styling Guidelines

- Use **Cinzel** font for titles
- Color palette: dark browns (#2b1810, #5a4022), gold accents (#d4a574, #c89a4a), cream backgrounds (#e6c998)
- Medieval/rusty aesthetic with textures and shadows
- Responsive design (desktop-first, mobile adjustments)

## Communication Style

- Be concise and direct
- Use markdown for code blocks
- Reference specific file paths and line numbers
- Suggest alternatives when appropriate
