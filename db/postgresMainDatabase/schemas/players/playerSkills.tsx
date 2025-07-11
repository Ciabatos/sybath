"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TPlayerSkills = {
  id: number
  player_id: number
  skill_id: number
  value: number
  name: string
}

export async function getPlayerSkills(playerId: number) {
  if (!playerId || isNaN(playerId)) {
    return null
  }

  try {
    const result = await query(`SELECT * FROM players.player_skills($1)`, [playerId])
    return result.rows as TPlayerSkills[]
  } catch (error) {
    console.error("Error fetching getPlayerSkills:", error)
    throw new Error("Failed to fetch getPlayerSkills")
  }
}
