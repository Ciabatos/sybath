---
description: Create custom hook for component
name: create-new-composite-hook
mode: primary
model: lmstudio2/qwen_qwen3.5-9b
temperature: 0.8
tools:
  write: true
  edit: true
color: "#1b9b34"
---

# Create New Composite Hook

## Task

Create a composite hook for the UI component specified below.

**Component name:** `$COMPONENT_NAME` **Component path:** `$COMPONENT_PATH`

---

## Steps

### 1. Read the component

Read the file at `$COMPONENT_PATH` and identify:

- What data the component consumes (variables, props, types)
- Which domains are involved (world, players, cities, districts, attributes, inventory, etc.)
- Whether `playerId`, `mapId`, or other context IDs are needed
- Which data sets could benefit from being merged into a `combined*` array

### 2. Scan available hooks

List all files under `methods/hooks/` recursively. For each domain relevant to the component, read the core hooks to
learn:

- Exact fetch hook names: `useFetch[Entity]`
- Exact state hook names: `use[Entity]State`
- Required parameters (e.g. `{ mapId, playerId }`)
- Available composite hooks that can be reused

### 3. Generate the composite hook

Create the file at:

```
methods/hooks/[domain]/composite/use$COMPONENT_NAME.ts
```

Follow this structure exactly:

```typescript
"use client"

// 1. Type imports (if needed for combined type definition)
// 2. Core/composite hook imports

export function use$COMPONENT_NAME() {
  // Context IDs first
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()

  // Fetch hooks (side effects, no assignment)
  useFetch[Entity]({ mapId, playerId })

  // State hooks (data reading)
  const [entity] = use[Entity]State()

  // Optional: combined data merging
  const combined[Entity] = Object.entries([entity]).map(([key, item]) => ({
    ...item,
    ...[relatedData][item.[foreignKey]],
  }))

  return { ... }
}
```

### 4. Rules

- Always start with `"use client"`
- Each `useFetch*` call is a standalone statement — never assign its return value unless the hook explicitly returns
  something useful
- Always call `useFetch*` before the corresponding `use*State`
- Only include `usePlayerId` / `useMapId` if the fetch hooks actually require those params
- Use `combined[Entity]` pattern when the component needs data from two stores merged by a foreign key
- Exports are named exports only, no default exports
- Import paths use `@/methods/hooks/[domain]/core/` and `@/methods/hooks/[domain]/composite/`
- Do not invent hook names — only use hooks that exist in `methods/hooks/`
- Do not add comments in the output file

### 5. Reference examples

**Example 1 — merging two stores:**

```typescript
"use client"

import {
  useAttributesSkillsState,
  useFetchAttributesSkills,
} from "@/methods/hooks/attributes/core/useFetchAttributesSkills"
import {
  useFetchOtherPlayerSkills,
  useOtherPlayerSkillsState,
} from "@/methods/hooks/attributes/core/useFetchOtherPlayerSkills"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function useOtherPlayerSkills() {
  const { playerId } = usePlayerId()
  const otherPlayerId = useOtherPlayerId()

  useFetchAttributesSkills()
  const skills = useAttributesSkillsState()

  useFetchOtherPlayerSkills({ playerId, otherPlayerId })
  const otherPlayerSkills = useOtherPlayerSkillsState()

  const combinedOtherPlayerSkills = Object.entries(otherPlayerSkills).map(([key, playerSkill]) => ({
    ...playerSkill,
    ...skills[playerSkill.skillId],
  }))

  return { skills, otherPlayerSkills, combinedOtherPlayerSkills }
}
```

**Example 2 — many domains, spatial key merging:**

```typescript
"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useFetchKnownMapTiles, useKnownMapTilesState } from "@/methods/hooks/world/core/useFetchKnownMapTiles"
import {
  useFetchWorldTerrainTypes,
  useWorldTerrainTypesState,
} from "@/methods/hooks/world/core/useFetchWorldTerrainTypes"

export function useMapHandling() {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()

  useFetchKnownMapTiles({ mapId, playerId })
  const knownMapTiles = useKnownMapTilesState()

  useFetchWorldTerrainTypes()
  const terrainTypes = useWorldTerrainTypesState()

  const combinedMap = Object.entries(knownMapTiles).map(([key, tile]) => ({
    mapTiles: tile,
    terrainTypes: tile.terrainTypeId ? terrainTypes[tile.terrainTypeId] : undefined,
  }))

  return { mapId, knownMapTiles, terrainTypes, combinedMap }
}
```
