// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TOtherPlayerAbilitiesParams = {
  playerId: number
  otherPlayerMaskId: string
}

export type TOtherPlayerAbilities = {
  abilityId: number
  value: number
  name: string
}

export type TOtherPlayerAbilitiesRecordByAbilityId = Record<string, TOtherPlayerAbilities>

export async function getOtherPlayerAbilities(params: TOtherPlayerAbilitiesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM attributes.get_other_player_abilities($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TOtherPlayerAbilities[]
  } catch (error) {
    console.error("Error fetching getOtherPlayerAbilities:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getOtherPlayerAbilities")
  }
}
