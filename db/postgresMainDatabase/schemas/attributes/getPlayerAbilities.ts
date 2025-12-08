// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TGetPlayerAbilitiesParams = {
  playerId: number
}

export type TGetPlayerAbilities = {
  abilityId: number
  value: number
  name: string
}

export type TGetPlayerAbilitiesRecordByAbilityId = Record<string, TGetPlayerAbilities>

export async function getPlayerAbilities(params: TGetPlayerAbilitiesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM attributes.get_player_abilities($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TGetPlayerAbilities[]
  } catch (error) {
    console.error("Error fetching getPlayerAbilities:", error)
    throw new Error("Failed to fetch getPlayerAbilities")
  }
}
