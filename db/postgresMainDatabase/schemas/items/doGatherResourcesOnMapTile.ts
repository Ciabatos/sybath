// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelKeys } from "@/methods/functions/util/snakeToCamel"

export type TDoGatherResourcesOnMapTileParams = {
  userId: string
  playerId: number
  mapId: number
  x: number
  y: number
  mapTilesResourceId: number
  gatherAmount: number
}

export type TDoGatherResourcesOnMapTile = {
  status: boolean
  message: string
}

export async function doGatherResourcesOnMapTile(params: TDoGatherResourcesOnMapTileParams) {
  try {
    const sqlParams = [
      params.userId,
      params.playerId,
      params.mapId,
      params.x,
      params.y,
      params.mapTilesResourceId,
      params.gatherAmount,
    ]
    const sql = `SELECT * FROM items.do_gather_resources_on_map_tile($1, $2, $3, $4, $5, $6, $7);`
    const result = await query(sql, sqlParams)

    return snakeToCamelKeys(result.rows[0]) as TDoGatherResourcesOnMapTile
  } catch (error) {
    console.error("Error executing doGatherResourcesOnMapTile:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to execute doGatherResourcesOnMapTile")
  }
}
