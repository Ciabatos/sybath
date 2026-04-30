// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerEnergyParams = {
  playerId: number
}

export type TPlayerEnergy = {
  currentEnergy: number
  maxEnergy: number
  lastRegeneratedAt: string
}

export type TPlayerEnergyRecordByLastRegeneratedAt = Record<string, TPlayerEnergy>

export async function getPlayerEnergy(params: TPlayerEnergyParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM attributes.get_player_energy($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerEnergy[]
  } catch (error) {
    console.error("Error fetching getPlayerEnergy:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getPlayerEnergy")
  }
}
