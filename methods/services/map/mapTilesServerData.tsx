"use server"

import { getMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import { getMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import { arrayToObjectKeyId } from "@/methods/util/converters"
import { joinMapTilesServer } from "@/methods/functions/joinMapTilesServer"
import { getMapsFieldsPlayerPosition, TMapsFieldsPlayerPosition } from "@/db/postgresMainDatabase/schemas/map/views/mapsFieldsPlayerPosition"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"

export async function mapTilesServerData() {
  const [mapTerrainTypes, tilesData, playerPosition] = await Promise.all([getMapTerrainTypes(), getMapTiles(), getMapsFieldsPlayerPosition()])

  const terrainTypesById = arrayToObjectKeyId("id", mapTerrainTypes) as Record<number, TMapTerrainTypes>

  const playerPositionById = arrayToObjectKeyId("map_field_id", playerPosition) as Record<number, TMapsFieldsPlayerPosition>

  const joinedMapTiles = joinMapTilesServer(tilesData, playerPositionById, terrainTypesById)

  console.log(playerPositionById, "playerPositionById")
  return { joinedMapTiles, terrainTypesById, playerPositionById }
}
