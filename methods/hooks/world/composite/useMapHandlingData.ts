"use client"

import { TCitiesCities } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TDistrictsDistricts } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TDistrictsDistrictTypes } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TKnownMapTiles } from "@/db/postgresMainDatabase/schemas/world/knownMapTiles"
import { TKnownPlayersPositions } from "@/db/postgresMainDatabase/schemas/world/knownPlayersPositions"
import { TWorldLandscapeTypes } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TPlayerPosition } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { TWorldTerrainTypes } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { useFetchCitiesCitiesByKey } from "@/methods/hooks/cities/core/useFetchCitiesCitiesByKey"
import { useFetchDistrictsDistrictsByKey } from "@/methods/hooks/districts/core/useFetchDistrictsDistrictsByKey"
import { useFetchDistrictsDistrictTypes } from "@/methods/hooks/districts/core/useFetchDistrictsDistrictTypes"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useFetchKnownMapTiles } from "@/methods/hooks/world/core/useFetchKnownMapTiles"
import { useFetchKnownPlayersPositions } from "@/methods/hooks/world/core/useFetchKnownPlayersPositions"
import { useFetchPlayerPosition } from "@/methods/hooks/world/core/useFetchPlayerPosition"
import { useFetchWorldLandscapeTypes } from "@/methods/hooks/world/core/useFetchWorldLandscapeTypes"
import { useFetchWorldTerrainTypes } from "@/methods/hooks/world/core/useFetchWorldTerrainTypes"
import {
  citiesAtom,
  districtsAtom,
  districtTypesAtom,
  knownMapTilesAtom,
  knownPlayersPositionsAtom,
  landscapeTypesAtom,
  playerPositionAtom,
  terrainTypesAtom,
} from "@/store/atoms"
import { useAtomValue } from "jotai"

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

export function useMapHandlingData() {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()

  useFetchKnownMapTiles({ mapId, playerId })
  const knownMapTiles = useAtomValue(knownMapTilesAtom)

  useFetchCitiesCitiesByKey({ mapId })
  const cities = useAtomValue(citiesAtom)

  useFetchPlayerPosition({ mapId, playerId })
  const playerPosition = useAtomValue(playerPositionAtom)

  useFetchKnownPlayersPositions({ mapId, playerId })
  const knownPlayersPositions = useAtomValue(knownPlayersPositionsAtom)

  useFetchDistrictsDistrictsByKey({ mapId })
  const districts = useAtomValue(districtsAtom)

  useFetchWorldTerrainTypes()
  const terrainTypes = useAtomValue(terrainTypesAtom)

  useFetchWorldLandscapeTypes()
  const landscapeTypes = useAtomValue(landscapeTypesAtom)

  useFetchDistrictsDistrictTypes()
  const districtTypes = useAtomValue(districtTypesAtom)

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
