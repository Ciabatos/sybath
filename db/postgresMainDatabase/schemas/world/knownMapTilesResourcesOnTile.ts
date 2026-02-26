// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TKnownMapTilesResourcesOnTileParams = {
  mapId: number
  mapTileX: number
  mapTileY: number
  playerId: number
}

export type TKnownMapTilesResourcesOnTile = {
  mapTilesResourceId: number
  itemId: number
  quantity: number
}

export type TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId = Record<string, TKnownMapTilesResourcesOnTile>

export async function getKnownMapTilesResourcesOnTile(params: TKnownMapTilesResourcesOnTileParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_known_map_tiles_resources_on_tile($1, $2, $3, $4);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TKnownMapTilesResourcesOnTile[]
  } catch (error) {
    console.error("Error fetching getKnownMapTilesResourcesOnTile:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getKnownMapTilesResourcesOnTile")
  }
}
