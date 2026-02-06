// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerMapParams = {
  playerId: number
}

export type TPlayerMap = {
  mapId: number
}

export type TPlayerMapRecordByMapId = Record<string, TPlayerMap>

export async function getPlayerMap(params: TPlayerMapParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_player_map($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerMap[]
  } catch (error) {
    console.error("Error fetching getPlayerMap:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getPlayerMap")
  }
}
