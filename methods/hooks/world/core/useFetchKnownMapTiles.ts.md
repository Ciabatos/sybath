# useFetchKnownMapTiles Hook Documentation

## Overview

`useFetchKnownMapTiles` is a client-side React hook that fetches and manages the fog-of-war knowledge of map tiles visible to a specific player. It implements SWR (Stale-While-Revalidate) caching with server-side cache synchronization via ETags, ensuring efficient data loading while respecting game visibility rules.

## What This Hook Does

### Primary Functionality
1. **Fetches known map tiles** for a given map and player combination from the PostgreSQL database
2. **Manages client-side state** by updating the `knownMapTilesAtom` Jotai atom with fetched data
3. **Implements caching strategy** using SWR built-in cache with 3-second refresh intervals
4. **Supports fog-of-war mechanics** - only returns tiles that a specific player has explored

### Data Flow
```
Component → useFetchKnownMapTiles → SWR Fetcher → API Route → Service Layer → PostgreSQL → Client State (Atom)
```

## Dependencies and Architecture

### 1. Jotai Atoms Integration

#### `knownMapTilesAtom`
- **Location**: `store/atoms.ts` line 105
- **Type**: `atom<TKnownMapTilesRecordByXY>({})`
- **Purpose**: Shared state container for all known map tiles across the application
- **Default Value**: Empty object `{}`

#### Hook Usage Pattern
```typescript
const setKnownMapTiles = useSetAtom(knownMapTilesAtom)  // For updating state
const knownMapTilesState = useKnownMapTilesState()      // For reading state (helper function)
```

### 2. SWR Fetcher Configuration

**SWR Options:**
- **Refresh Interval**: 3000ms (3 seconds)
- **Cache Key Format**: `/api/world/rpc/get-known-map-tiles/${mapId}/${playerId}`
- **Data Type**: `TKnownMapTiles[]`

### 3. TypeScript Types

```typescript
// Parameters
interface TKnownMapTilesParams {
  mapId: number
  playerId: number
}

// Data Structure
interface TKnownMapTiles {
  mapId: number
  x: number
  y: number
  terrainTypeId?: number
  landscapeTypeId?: number
}

// Record Format (used by atom)
type TKnownMapTilesRecordByXY = Record<string, TKnownMapTiles>

## PostgreSQL Database Integration

### Data Source Chain

#### 1. API Route Handler
**File**: `app/api/world/rpc/get-known-map-tiles/[mapId]/[playerId]/route.ts`

- **Authentication**: Verifies user session via NextAuth
- **Authorization**: Confirms requested playerId matches active player
- **ETag Support**: Handles conditional requests for cache optimization
- **Response**: Returns `record!.raw` (array of tile objects) or 304 Not Modified

#### 2. Service Layer
**File**: `methods/services/world/fetchKnownMapTilesService.ts`

**Cache Strategy:**
```typescript
const CACHE_TTL = 3_000 // 3 seconds
const { getCache, setCache, getEtag } = createServerCache<TCacheRecord>(CACHE_TTL)
```

**ETag Generation:**
- SHA1 hash of JSON.stringify(raw data)
- Used for HTTP conditional requests (If-None-Match header)

**Caching Behavior:**
1. Check server-side cache first
2. Compare ETags with client request
3. Return cached data if no changes detected
4. Fetch fresh data and update cache only when necessary

#### 3. Database Query Layer
**File**: `db/postgresMainDatabase/schemas/world/knownMapTiles.ts`

**SQL Function Called:**
```sql
SELECT * FROM world.get_known_map_tiles($1, $2);
-- Parameters: mapId, playerId
```

**PostgreSQL Tables Involved:**

| Table | Schema | Purpose |
|-------|--------|---------|
| `knowledge.known_map_tiles` | knowledge | Stores player explored tiles (fog-of-war) |
| `world.map_tiles` | world | Contains tile geometry and terrain data |

**SQL Query Logic:**
```sql
SELECT T1.map_id, T1.x, T1.y, T2.id AS terrain_type_id, T3.id AS landscape_type_id
FROM world.map_tiles T1
LEFT JOIN knowledge.known_map_tiles T2 ON T2.map_id = T1.map_id AND T2.map_tile_x = T1.x AND T2.map_tile_y = T1.y
LEFT JOIN world.terrain_types T2 ON T1.terrain_type_id = T2.id
LEFT JOIN world.landscape_types T3 ON T1.landscape_type_id = T3.id
WHERE T1.map_id = $1 AND T2.player_id = $2;
```

## Application Structure Supporting This Hook

### File Organization

```
methods/
├── hooks/
│   └── world/
│       ├── core/
│       │   └── useFetchKnownMapTiles.ts          ← Main hook
│       ├── composite/
│       │   ├── useMapHandling.ts                  ← Uses this hook
│       │   ├── useMapTilesPathFromPointToPoint.ts ← Uses this hook
│       │   └── useMapTileDetail.ts                ← Related (resources)
│       └── services/
│           └── fetchKnownMapTilesService.ts       ← Service layer
├── server-fetchers/
│   └── world/
│       └── core/
│           └── getKnownMapTilesServer.ts          ← Server-side wrapper
├── store/
│   └── atoms.ts                                   ← State management
└── db/postgresMainDatabase/schemas/world/
    ├── knownMapTiles.ts                           ← DB types & queries
    └── mapTiles.ts                                ← Map tile data
```

### Component Usage Examples

#### 1. `components/map/MapHandling.tsx`
```typescript
import { useFetchKnownMapTiles, useKnownMapTilesState } from "@/methods/hooks/world/core/useFetchKnownMapTiles"

useEffect(() => {
  useFetchKnownMapTiles({ mapId, playerId })
}, [mapId, playerId])

const knownMapTiles = useKnownMapTilesState()
```

#### 2. `components/map/Map.tsx`
- Renders only tiles present in `knownMapTilesAtom`
- Filters visible area based on fog-of-war knowledge

## Helper Functions

### `useKnownMapTilesState()`
**Purpose**: Read-only access to the known map tiles state
**Returns**: `TKnownMapTilesRecordByXY` (empty object `{}` by default)
**Usage**: Used in components that need to display or process known tiles

```typescript
const { data } = useKnownMapTilesState()
// Access via Object.entries(data) for iteration
```

## SWR Integration Details

### Fetcher Implementation
SWR automatically creates a fetcher from the API route:
- **URL Pattern**: `/api/world/rpc/get-known-map-tiles/${mapId}/${playerId}`
- **Method**: GET (handled by Next.js App Router)
- **Headers**: Includes ETag for cache validation

### Cache Behavior
```typescript
// SWR automatically caches responses
const { data, mutate } = useSWR(key, fetcher, { refreshInterval: 3000 })

// Manual revalidation when needed
mutate() // Re-fetches from server
```

## Data Transformation Pipeline

1. **Raw API Response**: `TKnownMapTiles[]` (array)
2. **Conversion Function**: `arrayToObjectKey(["x", "y"], data)`
3. **Atom State**: `Record<string, TKnownMapTiles>` keyed by `"${x},${y}"`
4. **Component Access**: Via `useKnownMapTilesState()` or direct atom reference

## Refresh Strategy

| Scenario | Behavior |
|----------|----------|
| Initial Load | Fetch immediately on mount |
| Periodic Update | Every 3 seconds (refreshInterval) |
| Map Change | Re-fetch with new mapId/playerId |
| Manual Trigger | Call `mutate()` from SWR return value |

## Error Handling

- **SWR**: Automatically handles fetch errors, returns `null` for data on failure
- **API Route**: Returns 401 (Unauthorized), 404 (Not Found), or 500 (Server Error)
- **Service Layer**: Logs errors with timestamp and parameters

## Related Hooks

| Hook | Purpose | Relationship |
|------|---------|--------------|
| `useFetchKnownMapTilesResourcesOnTile` | Fetch resources on specific tile | Complementary - gets resources for known tiles |
| `useMutateKnownMapTiles` | Manual mutation of known tiles state | Works with same atom |
| `useKnownPlayersPositions` | Fetch other players positions | Related fog-of-war data |

## Usage Example

```typescript
import { useFetchKnownMapTiles, useKnownMapTilesState } from "@/methods/hooks/world/core/useFetchKnownMapTiles"

export function MapComponent() {
  const { mapId, playerId } = usePlayerContext()

  // Fetch known map tiles with automatic caching
  useFetchKnownMapTiles({ mapId, playerId })

  // Access the state in components
  const knownMapTiles = useKnownMapTilesState()

  return <div>{/* render tiles */}</div>
}
```

## Performance Considerations

1. **Server-Side Caching**: Reduces database queries via service layer cache
2. **ETag Validation**: HTTP-level caching prevents unnecessary transfers
3. **SWR Deduplication**: Multiple components with same key share fetch result
4. **Atomic State Updates**: Single source of truth prevents race conditions

## Maintenance Notes

- **Generated Code**: This hook is auto-generated from templates - do not edit manually
- **Cache TTL**: Currently 3 seconds - adjust based on game pacing needs
- **Security**: playerId validation ensures players only see their own fog-of-war data

## Summary

`useFetchKnownMapTiles` is a critical hook for implementing fog-of-war mechanics in the game. It efficiently fetches and caches map tile knowledge while respecting player visibility rules, using SWR for client-side caching and server-side ETag validation for optimal performance.
