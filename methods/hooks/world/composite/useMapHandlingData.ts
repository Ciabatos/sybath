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
import {
  citiesAtom,
  districtsAtom,
  districtTypesAtom,
  landscapeTypesAtom,
  mapTilesAtom,
  playerPositionAtom,
  terrainTypesAtom,
} from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useMapHandlingData() {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()

  useFetchWorldMapTilesByKey({ mapId })
  const mapTiles = useAtomValue(mapTilesAtom)

  useFetchCitiesCitiesByKey({ mapId })
  const cities = useAtomValue(citiesAtom)

  useFetchPlayerPosition({ mapId, playerId })
  const playerPosition = useAtomValue(playerPositionAtom)

  useFetchDistrictsDistrictsByKey({ mapId })
  const districts = useAtomValue(districtsAtom)

  useFetchWorldTerrainTypes()
  const terrainTypes = useAtomValue(terrainTypesAtom)

  useFetchWorldLandscapeTypes()
  const landscapeTypes = useAtomValue(landscapeTypesAtom)

  useFetchDistrictsDistrictTypes()
  const districtTypes = useAtomValue(districtTypesAtom)

  return { mapId, mapTiles, cities, districts, districtTypes, playerPosition, terrainTypes, landscapeTypes }
}
