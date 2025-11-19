// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerAbilitiesParams = {
  playerId: number
}

export type TPlayerAbilities = {
  id: number
  playerId: number
  abilityId: number
  value: number
  name: string
}

export type TPlayerAbilitiesRecordByPlayerId = Record<number, TPlayerAbilities>

export async function getPlayerAbilities(params: TPlayerAbilitiesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM players.player_abilities($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerAbilities[]
  } catch (error) {
    console.error("Error fetching getPlayerAbilities:", error)
    throw new Error("Failed to fetch getPlayerAbilities")
  }
}
