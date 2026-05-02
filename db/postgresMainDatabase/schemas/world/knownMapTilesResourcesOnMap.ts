// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TKnownMapTilesResourcesOnMapParams = {
  mapId: number
  playerId: number
}

export type TCtItemIds = {
  itemId: number
}

export type TKnownMapTilesResourcesOnMap = {
  mapTileX: number
  mapTileY: number
  itemIds: TCtItemIds[]
}

export type TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY = Record<string, TKnownMapTilesResourcesOnMap>

export async function getKnownMapTilesResourcesOnMap(params: TKnownMapTilesResourcesOnMapParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_known_map_tiles_resources_on_map($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TKnownMapTilesResourcesOnMap[]
  } catch (error) {
    console.error("Error fetching getKnownMapTilesResourcesOnMap:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getKnownMapTilesResourcesOnMap")
  }
}
