"use client"

import { TCitiesCities } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TDistrictsDistricts } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TDistrictsDistrictTypes } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TKnownMapTiles } from "@/db/postgresMainDatabase/schemas/world/knownMapTiles"
import { TKnownPlayersPositions } from "@/db/postgresMainDatabase/schemas/world/knownPlayersPositions"
import { TWorldLandscapeTypes } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TPlayerPosition } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { TWorldTerrainTypes } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { useCitiesCitiesState, useFetchCitiesCitiesByKey } from "@/methods/hooks/cities/core/useFetchCitiesCitiesByKey"
import {
  useDistrictsDistrictsState,
  useFetchDistrictsDistrictsByKey,
} from "@/methods/hooks/districts/core/useFetchDistrictsDistrictsByKey"
import {
  useDistrictsDistrictTypesState,
  useFetchDistrictsDistrictTypes,
} from "@/methods/hooks/districts/core/useFetchDistrictsDistrictTypes"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useFetchKnownMapTiles, useKnownMapTilesState } from "@/methods/hooks/world/core/useFetchKnownMapTiles"
import {
  useFetchKnownPlayersPositions,
  useKnownPlayersPositionsState,
} from "@/methods/hooks/world/core/useFetchKnownPlayersPositions"
import { useFetchPlayerPosition, usePlayerPositionState } from "@/methods/hooks/world/core/useFetchPlayerPosition"
import {
  useFetchWorldLandscapeTypes,
  useWorldLandscapeTypesState,
} from "@/methods/hooks/world/core/useFetchWorldLandscapeTypes"
import {
  useFetchWorldTerrainTypes,
  useWorldTerrainTypesState,
} from "@/methods/hooks/world/core/useFetchWorldTerrainTypes"

export type TMapTile = {
  mapTiles: TKnownMapTiles
  terrainTypes?: TWorldTerrainTypes
  landscapeTypes?: TWorldLandscapeTypes
  cities?: TCitiesCities
  districts?: TDistrictsDistricts
  districtTypes?: TDistrictsDistrictTypes
  playerPosition?: TPlayerPosition
  knownPlayersPositions?: TKnownPlayersPositions
}

export function useMapHandling() {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()

  useFetchKnownMapTiles({ mapId, playerId })
  const knownMapTiles = useKnownMapTilesState()

  useFetchCitiesCitiesByKey({ mapId })
  const cities = useCitiesCitiesState()

  useFetchPlayerPosition({ mapId, playerId })
  const playerPosition = usePlayerPositionState()

  useFetchKnownPlayersPositions({ mapId, playerId })
  const knownPlayersPositions = useKnownPlayersPositionsState()
  console.log("knownPlayersPositions", knownPlayersPositions)
  useFetchDistrictsDistrictsByKey({ mapId })
  const districts = useDistrictsDistrictsState()

  useFetchWorldTerrainTypes()
  const terrainTypes = useWorldTerrainTypesState()

  useFetchWorldLandscapeTypes()
  const landscapeTypes = useWorldLandscapeTypesState()

  useFetchDistrictsDistrictTypes()
  const districtTypes = useDistrictsDistrictTypesState()

  const combinedMap: TMapTile[] = Object.entries(knownMapTiles).map(([key, tile]) => {
    const tileKey = `${tile.x},${tile.y}`
    const district = districts[tileKey]

    return {
      mapTiles: tile,
      terrainTypes: tile.terrainTypeId ? terrainTypes[tile.terrainTypeId] : undefined,
      landscapeTypes: tile.landscapeTypeId ? landscapeTypes[tile.landscapeTypeId] : undefined,
      cities: cities[tileKey],
      districts: district,
      districtTypes: district ? districtTypes[district.districtTypeId] : undefined,
      playerPosition: playerPosition[tileKey],
      knownPlayersPositions: knownPlayersPositions[tileKey],
    }
  })

  return {
    mapId,
    mapTiles: knownMapTiles,
    cities,
    districts,
    districtTypes,
    playerPosition,
    knownPlayersPositions,
    terrainTypes,
    landscapeTypes,
    combinedMap,
  }
}
