// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TOtherPlayerSkillsParams = {
  playerId: number
  otherPlayerMaskId: string
}

export type TOtherPlayerSkills = {
  skillId: number
  value: number
  name: string
}

export type TOtherPlayerSkillsRecordBySkillId = Record<string, TOtherPlayerSkills>

export async function getOtherPlayerSkills(params: TOtherPlayerSkillsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM attributes.get_other_player_skills($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TOtherPlayerSkills[]
  } catch (error) {
    console.error("Error fetching getOtherPlayerSkills:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getOtherPlayerSkills")
  }
}
