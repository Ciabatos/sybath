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
    const result = await query(
      `
     SELECT 
      T1.id
      ,T1.player_id
      ,T1.skill_id
      ,T1.value
      ,T2.name
    FROM players.player_skills T1
      JOIN players.skills T2 ON T1.skill_id = T2.id
      WHERE T1.player_id = $1 
    ORDER BY T1.id ASC`,
      [playerId],
    )
    return result.rows as TPlayerSkills[]
  } catch (error) {
    console.error("Error fetching getPlayerSkills:", error)
    throw new Error("Failed to fetch getPlayerSkills")
  }
}
