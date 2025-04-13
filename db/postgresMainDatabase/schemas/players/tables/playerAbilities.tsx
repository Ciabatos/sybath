"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TPlayerAbilities = {
  id: number
  player_id: number
  ability_id: number
  value: number
}

export const getPlayerAbilities = async (playerId: number) => {
  if (!playerId || isNaN(playerId)) {
    return null
  }

  try {
    const result = await query(`SELECT * FROM players.player_abilities WHERE player_id = $1 ORDER BY id ASC`, [playerId])
    return result.rows as TPlayerAbilities[]
  } catch (error) {
    console.error("Error fetching getPlayerAbilities:", error)
    throw new Error("Failed to fetch getPlayerAbilities")
  }
}
