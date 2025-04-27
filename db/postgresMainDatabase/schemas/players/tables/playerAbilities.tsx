"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TPlayerAbilities = {
  id: number
  player_id: number
  ability_id: number
  value: number
  name: string
}

export async function getPlayerAbilities(playerId: number) {
  if (!playerId || isNaN(playerId)) {
    return null
  }

  try {
    const result = await query(
      `
    SELECT 
	  T1.id
	  ,T1.player_id
	  ,T1.ability_id
	  ,T1.value
	  ,T2.name
    FROM players.player_abilities T1
	  JOIN players.abilities T2 ON T1.ability_id = T2.id
      WHERE T1.player_id = $1 
    ORDER BY T1.id ASC`,
      [playerId],
    )
    return result.rows as TPlayerAbilities[]
  } catch (error) {
    console.error("Error fetching getPlayerAbilities:", error)
    throw new Error("Failed to fetch getPlayerAbilities")
  }
}
