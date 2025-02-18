"use server"
import { getMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import { getMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import { arrayToObjectKeyId } from "@/functions/util/converters"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"

export type TjoinedMapTile = {
  id: number
  x: number
  y: number
  terrain_type_id: number
  terrain_name?: string
  terrain_move_cost?: number
}

async function mapTilesServerData() {
  const [mapTerrainTypes, tilesData] = await Promise.all([getMapTerrainTypes(), getMapTiles()])
  console.log("da")
  const terrainTypesById = arrayToObjectKeyId(mapTerrainTypes) as Record<number, TMapTerrainTypes>

  const joinedMapTiles = Object.fromEntries(
    tilesData.map((tile) => {
      const key = `${tile.x},${tile.y}`
      const terrain = terrainTypesById[tile.terrain_type_id]
      return [
        key,
        {
          ...tile,
          terrain_name: terrain?.name,
          terrain_move_cost: terrain?.terrain_move_cost,
        },
      ]
    }),
  ) as Record<string, TjoinedMapTile>

  return { terrainTypesById, joinedMapTiles }
}

export async function getTerrainTypesById() {
  const data = await mapTilesServerData()
  return data.terrainTypesById
}

export async function getJoinedMapTiles() {
  const data = await mapTilesServerData()
  return data.joinedMapTiles
}
