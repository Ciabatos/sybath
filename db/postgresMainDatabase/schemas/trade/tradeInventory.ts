// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TTradeInventoryParams = {
  playerId: number
  tradeId: number
}

export type TTradeInventory = {
  slotId: number
  containerId: number
  inventoryContainerTypeId: number
  inventorySlotTypeId: number
  itemId: number
  name: string
  quantity: number
  side: number
}

export type TTradeInventoryRecordBySlotId = Record<string, TTradeInventory>

export async function getTradeInventory(params: TTradeInventoryParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM trade.get_trade_inventory($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TTradeInventory[]
  } catch (error) {
    console.error("Error fetching getTradeInventory:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getTradeInventory")
  }
}
