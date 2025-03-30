"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TPlayerInventories = {
  id: number
  player_id: number
  inventory_size: number
}

export const getPlayerInventories = async () => {
  try {
    const result = await query("SELECT * FROM players.player_inventories")
    return result.rows as TPlayerInventories[]
  } catch (error) {
    console.error("Error fetching getPlayerInventories:", error)
    throw new Error("Failed to fetch getPlayerInventories")
  }
}

export const getPlayerInventory = async (playerId: number | undefined) => {
  if (!playerId || isNaN(playerId)) {
    return null
  }

  try {
    const result = await query(`SELECT * FROM players.player_inventories WHERE player_id = $1`, [playerId])
    return result.rows[0] as TPlayerInventories[]
  } catch (error) {
    console.error("Error fetching getPlayerInventory:", error)
    throw new Error("Failed to fetch getPlayerInventory")
  }
}
