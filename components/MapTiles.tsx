"use server"

import MapTile from "./MapTile"
import { getMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import { getMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"

import { arrayToObjectKeyId } from "@/functions/util/converters"

export interface TjoinedMapTilesObj {
  id: number
  x: number
  y: number
  terrain_type_id: number
  terrain_name?: string
  terrain_move_cost?: number
}

export default async function MapTiles() {
  const mapTerrainTypes = await getMapTerrainTypes()
  const mapTerrainTypesObj = arrayToObjectKeyId(mapTerrainTypes)

  const mapTiles = await getMapTiles()

  const joinedMapTilesObj: Record<string, TjoinedMapTilesObj> = Object.fromEntries(
    mapTiles.map((tile) => {
      const key = `${tile.x},${tile.y}`
      const terrainType = mapTerrainTypesObj[tile.terrain_type_id]
      return [
        key,
        {
          ...tile,
          terrain_name: terrainType?.name,
          terrain_move_cost: terrainType?.terrain_move_cost,
        },
      ]
    }),
  )

  return (
    <>
      {Object.entries(joinedMapTilesObj).map(([key, tile]) => (
        <MapTile
          key={key}
          tile={tile}
        />
      ))}
    </>
  )
}
