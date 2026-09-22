// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelKeys } from "@/methods/functions/util/snakeToCamel"

export type TDoMoveOrSwapItemParams = {
  userId: string
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
    const sqlParams = [
      params.userId,
      params.playerId,
      params.fromSlotId,
      params.toSlotId,
      params.fromInventoryContainerId,
      params.toInventoryContainerId,
    ]
    const sql = `SELECT * FROM inventory.do_move_or_swap_item($1, $2, $3, $4, $5, $6);`
    const result = await query(sql, sqlParams)

    return snakeToCamelKeys(result.rows[0]) as TDoMoveOrSwapItem
  } catch (error) {
    console.error("Error executing doMoveOrSwapItem:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to execute doMoveOrSwapItem")
  }
}
