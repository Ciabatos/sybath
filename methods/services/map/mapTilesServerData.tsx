"use server"
import { getMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import { getMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import { arrayToObjectKeyId } from "@/methods/util/converters"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import { joinMapTilesServer } from "@/methods/functions/joinMapTilesServer"

async function mapTilesServerData() {
  const [mapTerrainTypes, tilesData] = await Promise.all([getMapTerrainTypes(), getMapTiles()])

  const terrainTypesById = arrayToObjectKeyId(mapTerrainTypes) as Record<number, TMapTerrainTypes>

  const joinedMapTiles = joinMapTilesServer(tilesData, mapTerrainTypes)

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
