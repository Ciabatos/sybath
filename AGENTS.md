## Project overview

Medieval/fantasy multiplayer turn-based game with real-time elements.

## Tech Stack

- **Framework**: Next.js 16+ (App Router)
- **Language**: TypeScript
- **Styling**: CSS Modules (per-component)
- **Icons**: `lucide-react` `react-icons/gi`
- **UI Primitives**: shadcn/ui, kibo-ui

## Project Structure

- `components/` - Contains all components
- `components/ui` - Contains reusable primitives. To add new primitives use shadcn,kibo-ui . This is only for shadcn
  library, we dont make components here, only install them from shadcn mcp

## Component Rules

- Create components in `components/GeneratedComponents/ComponentName.tsx`
- Create styles for that components in `components/GeneratedComponents/styles/ComponentName.module.css`
- Use mock data only
- Functions should be stubbed
- No business logic inside components
- Use traditional function syntax (avoid unnecessary abstractions)

## Visual Style

All UI windows must resemble in-game RPG / grand strategy panels, inspired by: Crusader Kings

The interface should feel like a medieval strategy game UI, not a typical web dashboard.

Reference existing styles in `components/**/styles/` for consistency

Reference skill game-ui-design
