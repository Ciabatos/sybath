// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TDoMoveOrSwapItemParams = {
  playerId: number
  fromSlotId: number
  toSlotId: number
  fromInventoryContainerId: number
  toInventoryContainerId: number
}

export type TDoMoveOrSwapItem = {
  status: boolean
  message: string
}

export async function doMoveOrSwapItem(params: TDoMoveOrSwapItemParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM inventory.do_move_or_swap_item($1, $2, $3, $4, $5);`
    const result = await query(sql, sqlParams)


    return result.rows[0] as TDoMoveOrSwapItem
  } catch (error) {
    console.error("Error executing doMoveOrSwapItem:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })
    
    throw new Error("Failed to execute doMoveOrSwapItem")
  }
}
