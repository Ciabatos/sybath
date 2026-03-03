# AGENTS.md

## Project: Sybath - Medieval Equipment Game

## Overview

Sybath is a medieval-themed equipment management game built with React, TypeScript, and Tailwind CSS. Players collect,
equip, and manage various gear pieces including weapons, armor, shields, weapons mastery, accessories, and belts.

## Tech Stack

- **Frontend**: React (Vite)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Icons**: Lucide React
- **Architecture**: Component-based with type-safe state management

## Common Tasks You Can Help With

### Code Development

- Implement new equipment types or slots
- Add new weapon categories
- Create component variations (player, inventory, equipment views)
- Implement drag-and-drop functionality between player gear and inventory
- Add item selection and unequipping mechanics

### Refactoring & Cleanup

- Simplify complex component logic
- Extract repeated patterns into hooks
- Improve type definitions
- Optimize re-renders
- Clean up unused code

### Bug Fixes

- Fix state synchronization issues between player and inventory
- Resolve slot selection conflicts
- Fix drag-and-drop edge cases
- Debug component rendering issues
- Fix styling inconsistencies

### Testing

- Write unit tests for components
- Create integration tests for equipment flows
- Add type-checking tests
- Verify styling across breakpoints

### Documentation

- Add JSDoc comments to components
- Document type definitions
- Create API documentation
- Update README with new features

### Styling

- Create consistent medieval-themed styles
- Implement responsive layouts
- Add hover/interaction states
- Create reusable component styles

### Performance

- Optimize re-renders with memoization
- Implement virtual scrolling for large inventories
- Lazy load heavy assets
- Optimize bundle size

## Project Structure

```
src/
  components/
    Player/           # Player component and types
    Inventory/          # Inventory component and types
    Equipment/          # Equipment components and types
    PlayerGear/        # Player gear display component
  types/               # TypeScript type definitions
  styles/              # CSS modules for styling
```

## Equipment Slots

Each category has limited slots:

- **Weapons**: Primary + Special (e.g., Axe, Sword, Mace, Spear)
- **Armor**: Body + Back (e.g., Mail, Plate, Robe)
- **Shields**: Primary + Special (e.g., Shield, Bucklers)
- **Weapon Mastery**: 3 slots (Combat Expertise, Weapon Handling, Weapon Mastery)
- **Accessories**: Rings + Gloves (e.g., Iron Ring, Leather Ring, Steel Ring, Silver Ring, Gold Ring)
- **Belt**: Weapon slots + Special (up to 3)
- **Boots**: (future expansion)

## Styling Guidelines

- Use **Cinzel** font for titles
- Color palette: dark browns (#2b1810, #5a4022), gold accents (#d4a574, #c89a4a), cream backgrounds (#e6c998)
- Medieval/rusty aesthetic with textures and shadows
- Responsive design (desktop-first, mobile adjustments)

## Type Safety

- All components have corresponding `.types.ts` or `.types.tsx` files
- Interfaces define: Slots, Items, Selection states, Equipment types
- Avoid `any` types, use specific slot/item types

## Before Committing

- Run type check: `npm run type-check`
- Run lint: `npm run lint` (or equivalent)
- Verify no console errors
- Ensure no secrets/credentials exposed
- Test on multiple viewport sizes

## Known Patterns

**EquipmentSlot Component:**

```typescript
interface EquipmentSlotProps {
  slotId: number
  slotLabel: string
  itemSlot: ItemSlot
  typeSlot: ItemSlot
  selection: SelectableItem
  fillSlot: (item: SelectableItem | undefined) => void
  fillType: (type: SelectableItem | undefined) => void
  deselect: () => void
}
```

**Player Component Structure:**

```typescript
interface PlayerProps {
  headSlot: ItemSlot
  armorSlot: ItemSlot
  legSlot: ItemSlot
  feetSlot: ItemSlot
  weaponSlotA: ItemSlot
  weaponSlotB: ItemSlot
  shieldSlot: ItemSlot
  ringSlot: ItemSlot[]
  gloveSlot: ItemSlot[]
  beltSlot: ItemSlot[]
  beltSlot2: ItemSlot[]
  weaponMasterySlot: ItemSlot[]
}
```

## Communication Style

- Be concise and direct
- Use markdown for code blocks
- Reference specific file paths and line numbers
- Suggest alternatives when appropriate

## Important Notes

- Never commit sensitive information
- Always validate type definitions before implementation
- Follow existing naming conventions (PascalCase for components, camelCase for utilities)
- Maintain TypeScript strict checking
