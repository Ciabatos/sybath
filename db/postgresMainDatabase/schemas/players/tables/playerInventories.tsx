"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TPlayerInventories = {
  player_inventory_id: number
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
