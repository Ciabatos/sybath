"use server"
import { getMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import { getMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import { arrayToObjectKeyId } from "@/functions/util/converters"
import MapWrapper from "@/components/MapWrapper"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"

export type TjoinedMapTiles = {
  id: number
  x: number
  y: number
  terrain_type_id: number
  terrain_name?: string
  terrain_move_cost?: number
}

export default async function MapTilesServer() {
  const mapTerrainTypes = await getMapTerrainTypes()
  const mapTerrainTypesById: Record<string, TMapTerrainTypes> = arrayToObjectKeyId(mapTerrainTypes)

  const mapTiles = await getMapTiles()

  const joinedMapTiles: Record<string, TjoinedMapTiles> = Object.fromEntries(
    mapTiles.map((tile) => {
      const key = `${tile.x},${tile.y}`
      const terrainType = mapTerrainTypesById[tile.terrain_type_id]
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
    <MapWrapper
      joinedMapTiles={joinedMapTiles}
      mapTerrainTypesById={mapTerrainTypesById}
    />
  )
}
