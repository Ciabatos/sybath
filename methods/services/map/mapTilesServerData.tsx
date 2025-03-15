"use server"

import { getMapLandscapeTypes, TMapLandscapeTypes } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import { getMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { getMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"

import { arrayToObjectKeyId } from "@/methods/functions/converters"
import { joinMapTilesServer } from "@/methods/functions/joinMapTilesServer"

export async function mapTilesServerData() {
  const [mapTerrainTypes, tilesData, mapLandscapeTypes] = await Promise.all([getMapTerrainTypes(), getMapTiles(), getMapLandscapeTypes()])

  const terrainTypesById = arrayToObjectKeyId("id", mapTerrainTypes) as Record<number, TMapTerrainTypes>

  const landscapeTypesById = arrayToObjectKeyId("id", mapLandscapeTypes) as Record<number, TMapLandscapeTypes>

  const joinedMapTiles = joinMapTilesServer(tilesData, terrainTypesById, landscapeTypesById)

  return { joinedMapTiles, terrainTypesById, landscapeTypesById }
}
