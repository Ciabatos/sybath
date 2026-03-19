# useFetchWorldTerrainTypesByKey – Documentation

## Overview

This hook fetches terrain type data for a specific ID from the PostgreSQL database and manages it in a Jotai atom. It's designed to provide cached, reusable access to world terrain reference data with automatic SWR caching and state synchronization.

> **Example:** _"Fetches terrain types by ID (e.g., grass, forest, mountain) and updates the global terrainTypesAtom for use across components."_

---

## Primary Functionality

- Fetches terrain type records from `/api/world/terrain-types/:id` endpoint
- Converts array response to key-value object indexed by `id` field
- Updates shared state in `terrainTypesAtom` atom
- Provides automatic refresh every 3 seconds via SWR
- Exposes companion hook `useWorldTerrainTypesState()` for reading the atom value

---

## Data Flow Diagram

```mermaid
flowchart TD
    A[Component] --> B[useFetchWorldTerrainTypesByKey]
    B --> C[SWR Fetcher]
    C --> D[/api/world/terrain-types/:id]
    D --> E[(world.terrain_types)]
    B --> F[terrainTypesAtom]
    F --> G[Components]
```

---

## Dependencies and Architecture

### State Management (Jotai)

| Atom | Type | Default | Purpose |
|------|------|---------|---------|
| `terrainTypesAtom` | `Record<number, TWorldTerrainTypes>` | `{}` | Stores terrain types indexed by ID for global access |

**Usage patterns:**

- `useSetAtom(terrainTypesAtom)` – Used to update the atom with fetched data converted from array to object format
- `useAtomValue(terrainTypesAtom)` – Used in companion hook `useWorldTerrainTypesState()` to read current state

### Data Fetching (SWR)

| Property | Value |
|----------|-------|
| Mechanism | SWR with refresh interval of 3000 ms |
| Cache key | `` `/api/world/terrain-types/${params.id}` `` |
| `deduplicatingInterval` | Default SWR behavior (5s) |
| `refreshInterval` | 3000 ms |

---

## TypeScript Types

```typescript
interface HookParameters {
  id: number // Required - terrain type ID to fetch
}

interface DataType {
  [id: number]: TWorldTerrainTypesRecordById
}

interface TWorldTerrainTypesParams {
  id: number
}

interface TWorldTerrainTypesRecordById {
  [id: number]: {
    id: number
    name: string
    move_cost: number | null
    image_url: string | null
  }
}
```

---

## Backend Integration

### API Endpoint

| Property | Value |
|----------|-------|
| URL | `/api/world/terrain-types/:id` |
| Method | `GET` |
| Parameters | `id` (number) - terrain type ID |
| Response | Array of `TWorldTerrainTypes[]` objects |

### Service Layer

No custom service layer - uses direct SWR fetch to API endpoint. No ETag or Redis caching configured at this level.

### Database Layer

**Tables / views used:**

| Table / View | Usage |
|--------------|-------|
| `world.terrain_types` | Source of terrain type reference data (id, name, move_cost, image_url) |

**Example SQL query:**

```sql
SELECT id, name, move_cost, image_url
FROM world.terrain_types
WHERE id = $1;
```

---

## Project File Structure

```
methods/
├── hooks/
│   └── world/
│       └── core/
│           ├── useFetchWorldTerrainTypesByKey.ts          ← main hook
│           └── useWorldTerrainTypesState.ts               ← companion getter
├── store/
│   └── atoms.ts                                           ← terrainTypesAtom definition
├── db/
│   └── postgresMainDatabase/
│       └── schemas/world/terrainTypes.ts                  ← TypeScript types
└── methods/
    └── functions/util/
        └── converters.ts                                  ← arrayToObjectKey helper
```

---

## Usage Examples in Components

```tsx
import { useFetchWorldTerrainTypesByKey, useWorldTerrainTypesState } from '@/methods/hooks/world/core'

function GameMapComponent() {
  // Fetch terrain type with ID = 3 (e.g., "forest")
  useFetchWorldTerrainTypesByKey({ id: 3 })
  
  // Access the terrain types data in this component
  const terrainTypes = useWorldTerrainTypesState()
  
  return (
    <div>
      {terrainTypes[3]?.name && (
        <span>{terrainTypes[3].name}</span>
      )}
    </div>
  )
}
```

---

## Helper / Related Hooks

| Hook | Description |
|------|-------------|
| `useWorldTerrainTypesState()` | Reads the current value of terrainTypesAtom - companion getter hook |
| `useFetchWorldLandscapeTypesByKey()` | Similar pattern for landscape types data |
| `useFetchWorldMapTilesByKey()` | Fetches map tiles with similar caching strategy |

---

## Data Transformation

```ts
// Input from API: [{ id: 1, name: "Grass", move_cost: 1 }, { id: 2, name: "Forest", move_cost: 2 }]
// Output in atom: { 1: { id: 1, name: "Grass", move_cost: 1 }, 2: { id: 2, name: "Forest", move_cost: 2 } }

const terrainTypes = arrayToObjectKey(["id"], data) as TWorldTerrainTypesRecordById
```

The `arrayToObjectKey` helper converts the API response array into an object keyed by the specified field (`"id"`).

---

## Refresh and Caching Strategy

| Stage | Behaviour |
|-------|-----------|
| Initial load | SWR fetches on mount with key `` `/api/world/terrain-types/${params.id}` `` |
| Periodic refresh | Automatic refetch every 3000 ms (3 seconds) |
| Manual invalidation | Call `useSWR(...).mutate()` to force immediate refetch |
| Parameter change | Hook must be re-mounted with new params to fetch different ID |

---

## Error Handling

- **Fetch error:** SWR returns `null` for data, useEffect skips update, atom retains previous value
- **Missing data:** Atom contains empty object `{}` if no prior data exists
- **Network timeout:** SWR default retry behavior (3 retries with exponential backoff)

---

## Performance Considerations

- **Client-side caching:** SWR deduplication prevents duplicate requests for same ID across components
- **Server-side caching:** No custom ETag/Redis - relies on Next.js API route caching
- **Re-render prevention:** Atom updates only when data changes, preventing unnecessary re-renders

---

## Maintenance Notes

> ⚠️ **DO NOT EDIT MANUALLY** – This file is auto-generated by template `hookGetTableByKey.hbs`

To modify this hook:
1. Update the SWR refresh interval in line 18 (`refreshInterval: 3000`)
2. Modify the SQL query in the backend API route `/api/world/terrain-types/[id]`
3. Update TypeScript types in `db/postgresMainDatabase/schemas/world/terrainTypes.ts`

---

## Summary

This hook provides a standardized pattern for fetching reference data (dictionary tables) from the PostgreSQL database and managing it globally via Jotai atoms. It solves the problem of scattered, redundant fetches by centralizing state management with automatic caching. Other hooks depend on `terrainTypesAtom` to access terrain type information without making their own API calls.

