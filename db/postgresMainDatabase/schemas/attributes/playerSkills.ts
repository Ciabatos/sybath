// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TAttributesPlayerSkillsParams = {
  playerId: number
}

export type TAttributesPlayerSkills = {
  id: number
  playerId: number
  skillId: number
  value: number
}

export type TAttributesPlayerSkillsRecordByPlayerId = Record<string, TAttributesPlayerSkills>

export async function getAttributesPlayerSkills() {
  try {
    const sql = `SELECT * FROM attributes.get_player_skills();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TAttributesPlayerSkills[]
  } catch (error) {
    console.error("Error fetching getAttributesPlayerSkills:", error)
    throw new Error("Failed to fetch getAttributesPlayerSkills")
  }
}

export async function getAttributesPlayerSkillsByKey(params: TAttributesPlayerSkillsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM attributes.get_player_skills_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TAttributesPlayerSkills[]
  } catch (error) {
    console.error("Error fetching getAttributesPlayerSkillsByKey:", error)
    throw new Error("Failed to fetch getAttributesPlayerSkillsByKey")
  }
}
