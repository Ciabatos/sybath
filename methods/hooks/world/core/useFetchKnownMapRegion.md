# useFetchKnownMapRegion Hook Documentation

## Overview

`useFetchKnownMapRegion` is a custom React hook that fetches and manages **known map region data** for a specific player on a given map. It retrieves regional information (such as borders, images, and names) from the PostgreSQL database and stores it in a Jotai atom for efficient access across components.

---

## What This Hook Does

### Primary Functionality
- Fetches known map regions for a specific **map**, **player**, and **region type**
- Converts raw array data into an object keyed by `mapTileX` and `mapTileY` coordinates
- Stores the result in a shared atom (`knownMapRegionAtom`) for use across components
- Automatically refreshes data every 3 seconds via SWR

### Data Structure
The hook works with **TKnownMapRegion** records containing:

```typescript
{
  regionId: number,           // Unique identifier for the region
  mapId: number,              // Map identifier
  mapTileX: number,           // X coordinate of the tile
  mapTileY: number,           // Y coordinate of the tile
  regionName: string,         // Name of the region
  imageFill: string,          // Fill color/image for the region
  imageOutline: string        // Outline color/image for the region
}

```

---

## Dependencies & Architecture

### React Hooks Used
| Hook | Purpose |
|------|---------|
|  (swr) | Data fetching with caching and auto-refresh |
| ,  (jotai) | State management for shared data |
|  (react) | Synchronize SWR data with atom state |

### Atoms Used
- **Input**: None (consumes params object)
- **Output**: `knownMapRegionAtom` - Stores region data keyed by coordinates

### Related Hooks
| Hook | Relationship | Location |
|------|-------------|----------|
|  | Returns current atom value | Same file (line 31) |
|  | Composite hook that uses this hook | methods/hooks/world/composite/useRegionLayerProvince.ts |
