// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TAttributesPlayerAbilitiesParams = {
  playerId: number
}

export type TAttributesPlayerAbilities = {
  id: number
  playerId: number
  abilityId: number
  value: number
}

export type TAttributesPlayerAbilitiesRecordByPlayerId = Record<string, TAttributesPlayerAbilities>

export async function getAttributesPlayerAbilities() {
  try {
    const sql = `SELECT * FROM attributes.get_player_abilities();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TAttributesPlayerAbilities[]
  } catch (error) {
    console.error("Error fetching getAttributesPlayerAbilities:", error)
    throw new Error("Failed to fetch getAttributesPlayerAbilities")
  }
}

export async function getAttributesPlayerAbilitiesByKey(params: TAttributesPlayerAbilitiesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM attributes.get_player_abilities_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TAttributesPlayerAbilities[]
  } catch (error) {
    console.error("Error fetching getAttributesPlayerAbilitiesByKey:", error)
    throw new Error("Failed to fetch getAttributesPlayerAbilitiesByKey")
  }
}
