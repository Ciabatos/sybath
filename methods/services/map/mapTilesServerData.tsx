"use server"

import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import { getMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import { getMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import { getMapsFieldsPlayerPosition, TMapsFieldsPlayerPosition } from "@/db/postgresMainDatabase/schemas/map/views/mapsFieldsPlayerPosition"
import { arrayToObjectKeyId } from "@/methods/functions/converters"
import { joinMapTilesServer } from "@/methods/functions/joinMapTilesServer"

export async function mapTilesServerData() {
  const [mapTerrainTypes, tilesData, playerPosition] = await Promise.all([getMapTerrainTypes(), getMapTiles(), getMapsFieldsPlayerPosition()])

  const terrainTypesById = arrayToObjectKeyId("id", mapTerrainTypes) as Record<number, TMapTerrainTypes>

  const playerPositionById = playerPosition ? (arrayToObjectKeyId("map_field_id", playerPosition) as Record<number, TMapsFieldsPlayerPosition>) : {}

  const joinedMapTiles = joinMapTilesServer(tilesData, playerPositionById, terrainTypesById)

  return { joinedMapTiles, terrainTypesById, playerPositionById }
}
