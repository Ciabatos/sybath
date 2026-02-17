"use client"

import { TCitiesCities } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TDistrictsDistricts } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TDistrictsDistrictTypes } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TWorldLandscapeTypes } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldMapTiles } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TPlayerPosition } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { TWorldTerrainTypes } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { playerMovementPlannedAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export type TMapTile = {
  mapTiles: TWorldMapTiles
  terrainTypes: TWorldTerrainTypes
  landscapeTypes?: TWorldLandscapeTypes
  cities?: TCitiesCities
  districts?: TDistrictsDistricts
  districtTypes?: TDistrictsDistrictTypes
  playerPosition?: TPlayerPosition
}

export default function TileLayerPlayerMovementPlanned(props: TMapTile) {
  const playerMovementPlanned = useAtomValue(playerMovementPlannedAtom)

  const layerData = playerMovementPlanned[`${props.mapTiles.x},${props.mapTiles.y}`]

  if (!layerData) {
    return null
  }

  return (
    <>
      {/* <p>{layerData.moveCost}</p> */}
      <svg
        fill='none'
        xmlns='http://www.w3.org/2000/svg'
        style={{ position: "absolute", top: 0, left: 0, width: "100%", height: "100%" }}
      >
        <rect
          width='100%'
          height='100%'
          fill='blue'
          opacity={0.5}
        />
      </svg>
    </>
  )
}
