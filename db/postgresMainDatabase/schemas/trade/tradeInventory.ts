// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TTradeInventoryParams = {
  userId: string
  playerId: number
  tradeId: number
}

export type TTradeInventoryClientParams = Omit<TTradeInventoryParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TTradeInventoryFetchParams = Partial<TTradeInventoryClientParams>

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
    const sqlParams = [params.userId, params.playerId, params.tradeId]
    const sql = `SELECT * FROM trade.get_trade_inventory($1, $2, $3);`

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
