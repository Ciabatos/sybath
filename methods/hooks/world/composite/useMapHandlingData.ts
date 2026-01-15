"use client"

import { useFetchCitiesCitiesByKey } from "@/methods/hooks/cities/core/useFetchCitiesCitiesByKey"
import { useFetchDistrictsDistrictsByKey } from "@/methods/hooks/districts/core/useFetchDistrictsDistrictsByKey"
import { useFetchDistrictsDistrictTypes } from "@/methods/hooks/districts/core/useFetchDistrictsDistrictTypes"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useFetchPlayerPosition } from "@/methods/hooks/world/core/useFetchPlayerPosition"
import { useFetchWorldLandscapeTypes } from "@/methods/hooks/world/core/useFetchWorldLandscapeTypes"
import { useFetchWorldMapTilesByKey } from "@/methods/hooks/world/core/useFetchWorldMapTilesByKey"
import { useFetchWorldTerrainTypes } from "@/methods/hooks/world/core/useFetchWorldTerrainTypes"
import { playerPositionAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useMapHandlingData() {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()
  const { mapTiles } = useFetchWorldMapTilesByKey({ mapId })
  const { cities } = useFetchCitiesCitiesByKey({ mapId })

  useFetchPlayerPosition({ mapId, playerId })
  const playerPosition = useAtomValue(playerPositionAtom)

  const { districts } = useFetchDistrictsDistrictsByKey({ mapId })
  const { terrainTypes } = useFetchWorldTerrainTypes()
  const { landscapeTypes } = useFetchWorldLandscapeTypes()
  const { districtTypes } = useFetchDistrictsDistrictTypes()

  return { mapId, mapTiles, cities, districts, districtTypes, playerPosition, terrainTypes, landscapeTypes }
}
