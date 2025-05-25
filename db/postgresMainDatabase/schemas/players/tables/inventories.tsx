"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TInventorySlots = {
  row: number
  col: number
  inventory_container_id: number
  item_id: number | null
  quantity: number | null
}

export async function getInventorySlots(playerId: number) {
  if (!playerId || isNaN(playerId)) {
    return null
  }

  try {
    const result = await query(`SELECT * FROM players.player_inventory($1)`, [playerId])
    return result.rows as TInventorySlots[]
  } catch (error) {
    console.error("Error fetching getInventory:", error)
    throw new Error("Failed to fetch getInventory")
  }
}
