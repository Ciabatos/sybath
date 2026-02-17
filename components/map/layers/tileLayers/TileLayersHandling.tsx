"use client"

import TileLayerPlayerMovement from "@/components/map/layers/tileLayers/players/TileLayerPlayerMovement"
import TileLayerPlayerMovementPlanned from "@/components/map/layers/tileLayers/players/TileLayerPlayerMovementPlanned"
import { TCitiesCities } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TDistrictsDistricts } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TDistrictsDistrictTypes } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TWorldLandscapeTypes } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldMapTiles } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TPlayerPosition } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { TWorldTerrainTypes } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"

export type TMapTile = {
  mapTiles: TWorldMapTiles
  terrainTypes: TWorldTerrainTypes
  landscapeTypes?: TWorldLandscapeTypes
  cities?: TCitiesCities
  districts?: TDistrictsDistricts
  districtTypes?: TDistrictsDistrictTypes
  playerPosition?: TPlayerPosition
}

export default function TileLayersHandling(props: TMapTile) {
  return (
    <>
      <TileLayerPlayerMovement {...props} />
      <TileLayerPlayerMovementPlanned {...props} />
    </>
  )
}
