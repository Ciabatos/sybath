// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelKeys } from "@/methods/functions/util/snakeToCamel"

export type TDoMapTileExplorationParams = {
  userId: string
  playerId: number
  mapId: number
  x: number
  y: number
  explorationLevel: number
}

export type TDoMapTileExploration = {
  status: boolean
  message: string
}

export async function doMapTileExploration(params: TDoMapTileExplorationParams) {
  try {
    const sqlParams = [params.userId, params.playerId, params.mapId, params.x, params.y, params.explorationLevel]
    const sql = `SELECT * FROM world.do_map_tile_exploration($1, $2, $3, $4, $5, $6);`
    const result = await query(sql, sqlParams)

    return snakeToCamelKeys(result.rows[0]) as TDoMapTileExploration
  } catch (error) {
    console.error("Error executing doMapTileExploration:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to execute doMapTileExploration")
  }
}
