// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TDoGatherResourcesOnMapTileParams = {
  playerId: number
  parameters: any
}

export type TDoGatherResourcesOnMapTile = {
  status: boolean
  message: string
}

export async function doGatherResourcesOnMapTile(params: TDoGatherResourcesOnMapTileParams) {
  try {
    const sqlParams = [params.playerId, JSON.stringify(params.parameters)]
    const sql = `SELECT * FROM items.do_gather_resources_on_map_tile($1, $2);`
    const result = await query(sql, sqlParams)

    return result.rows[0] as TDoGatherResourcesOnMapTile
  } catch (error) {
    console.error("Error executing doGatherResourcesOnMapTile:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to execute doGatherResourcesOnMapTile")
  }
}
