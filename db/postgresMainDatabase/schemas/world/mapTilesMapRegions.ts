// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TWorldMapTilesMapRegionsParams = {
  mapId: number
}

export type TWorldMapTilesMapRegions = {
  regionId: number
  mapId: number
  mapTileX: number
  mapTileY: number
}

export type TWorldMapTilesMapRegionsRecordByMapTileXMapTileY = Record<string, TWorldMapTilesMapRegions>

export async function getWorldMapTilesMapRegions() {
  try {
    const sql = `SELECT * FROM world.get_map_tiles_map_regions();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TWorldMapTilesMapRegions[]
  } catch (error) {
    console.error("Error fetching getWorldMapTilesMapRegions:", {
      error,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getWorldMapTilesMapRegions")
  }
}

export async function getWorldMapTilesMapRegionsByKey(params: TWorldMapTilesMapRegionsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_map_tiles_map_regions_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TWorldMapTilesMapRegions[]
  } catch (error) {
    console.error("Error fetching getWorldMapTilesMapRegionsByKey:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getWorldMapTilesMapRegionsByKey")
  }
}
