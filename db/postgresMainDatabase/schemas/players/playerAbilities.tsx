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
    const result = await query(`SELECT * FROM players.player_abilities($1)`, [playerId])
    return result.rows as TPlayerAbilities[]
  } catch (error) {
    console.error("Error fetching getPlayerAbilities:", error)
    throw new Error("Failed to fetch getPlayerAbilities")
  }
}
