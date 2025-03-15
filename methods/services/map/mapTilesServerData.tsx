"use server"

import { getMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { getMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"

import { arrayToObjectKeyId } from "@/methods/functions/converters"
import { joinMapTilesServer } from "@/methods/functions/joinMapTilesServer"

export async function mapTilesServerData() {
  const [mapTerrainTypes, tilesData] = await Promise.all([getMapTerrainTypes(), getMapTiles()])

  const terrainTypesById = arrayToObjectKeyId("id", mapTerrainTypes) as Record<number, TMapTerrainTypes>

  const joinedMapTiles = joinMapTilesServer(tilesData, terrainTypesById)

  return { joinedMapTiles, terrainTypesById }
}
