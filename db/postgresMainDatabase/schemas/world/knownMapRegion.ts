// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TKnownMapRegionParams = {
  mapId: number
  playerId: number
  regionType: number
}

export type TKnownMapRegion = {
  regionId: number
  mapId: number
  mapTileX: number
  mapTileY: number
  regionName: string
  imageFill: string
  imageOutline: string
}

export type TKnownMapRegionRecordByMapTileXMapTileY = Record<string, TKnownMapRegion>

export async function getKnownMapRegion(params: TKnownMapRegionParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_known_map_region($1, $2, $3);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TKnownMapRegion[]
  } catch (error) {
    console.error("Error fetching getKnownMapRegion:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getKnownMapRegion")
  }
}
