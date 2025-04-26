import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { TInventorySlots } from "@/db/postgresMainDatabase/schemas/players/tables/inventories"

export type TAddItemToInventory = Pick<TInventorySlots, "item_id" | "quantity"> & {
  playerId: number
}

export async function addItemToInventory({ playerId, item_id, quantity }: TAddItemToInventory) {
  try {
    const result = await query(
      `
	CALL players.add_item_to_inventory(
    p_player_id := $1,
    p_item_id := $2,
    p_quantity := $3  
		);`,
      [playerId, item_id, quantity],
    )
    return result.rows as TInventorySlots[]
  } catch (error) {
    console.error("Error fetching addItemToInventory:", error)
    throw new Error("Failed to fetch addItemToInventory")
  }
}
