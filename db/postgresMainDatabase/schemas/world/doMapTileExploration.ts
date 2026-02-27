// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TDoMapTileExplorationParams = {
  playerId: number
  parameters: any
}

export type TDoMapTileExploration = {
  status: boolean
  message: string
}

export async function doMapTileExploration(params: TDoMapTileExplorationParams) {
  try {
    const sqlParams = [params.playerId, JSON.stringify(params.parameters)]
    const sql = `SELECT * FROM world.do_map_tile_exploration($1, $2);`
    const result = await query(sql, sqlParams)

    return result.rows[0] as TDoMapTileExploration
  } catch (error) {
    console.error("Error executing doMapTileExploration:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to execute doMapTileExploration")
  }
}
