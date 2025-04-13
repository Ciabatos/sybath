"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TInventorySlots = {
  row: number
  col: number
  inventory_container_id: number
  item_id: number | null
  quantity: number | null
}

export const getInventorySlots = async (playerId: number) => {
  if (!playerId || isNaN(playerId)) {
    return null
  }

  try {
    const result = await query(
      `
							SELECT 
              T2.row
              ,T2.col
              ,T2.inventory_container_id
              ,T2.item_id
              ,T2.quantity
              FROM players.inventory_containers T1
              JOIN players.inventory_slots T2 ON T2.inventory_container_id= T1.id
		WHERE T1.player_id = $1`,
      [playerId],
    )
    return result.rows as TInventorySlots[]
  } catch (error) {
    console.error("Error fetching getInventory:", error)
    throw new Error("Failed to fetch getInventory")
  }
}
