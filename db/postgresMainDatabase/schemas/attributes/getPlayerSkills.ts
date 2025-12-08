// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TGetPlayerSkillsParams = {
  playerId: number
}

export type TGetPlayerSkills = {
  skillId: number
  value: number
  name: string
}

export type TGetPlayerSkillsRecordBySkillId = Record<string, TGetPlayerSkills>

export async function getPlayerSkills(params: TGetPlayerSkillsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM attributes.get_player_skills($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TGetPlayerSkills[]
  } catch (error) {
    console.error("Error fetching getPlayerSkills:", error)
    throw new Error("Failed to fetch getPlayerSkills")
  }
}
