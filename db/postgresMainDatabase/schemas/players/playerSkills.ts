// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerSkillsParams = {
  playerId: number
}

export type TPlayerSkills = {
  id: number
  playerId: number
  skillId: number
  value: number
  name: string
}

export type TPlayerSkillsRecordByPlayerId = Record<number, TPlayerSkills>

export async function getPlayerSkills(params: TPlayerSkillsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM players.player_skills($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerSkills[]
  } catch (error) {
    console.error("Error fetching getPlayerSkills:", error)
    throw new Error("Failed to fetch getPlayerSkills")
  }
}
