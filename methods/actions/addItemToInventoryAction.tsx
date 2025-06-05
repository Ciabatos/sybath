"use server"

import { TAddItemToInventory, addItemToInventory } from "@/db/postgresMainDatabase/schemas/players/procedures/addItemToInventory"

export async function addItemToInventoryAction({ playerId, item_id, quantity }: TAddItemToInventory) {
  try {
    await addItemToInventory({ playerId, item_id, quantity })
  } catch (error) {
    console.error("Error addItemToInventoryAction :", error)
    // throw new Error("Failed to sing up")
    return "Failed to addItemToInventoryAction"
  }
}
