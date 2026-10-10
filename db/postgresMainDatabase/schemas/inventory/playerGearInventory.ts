// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerGearInventoryParams = {
  userId: string
  playerId: number
}

export type TPlayerGearInventoryClientParams = Omit<TPlayerGearInventoryParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TPlayerGearInventoryFetchParams = Partial<TPlayerGearInventoryClientParams>

export type TPlayerGearInventory = {
  slotId: number
  containerId: number
  inventoryContainerTypeId: number
  inventorySlotTypeId: number
  itemId: number
  name: string
  quantity: number
}

export type TPlayerGearInventoryRecordBySlotId = Record<string, TPlayerGearInventory>

export async function getPlayerGearInventory(params: TPlayerGearInventoryParams) {
  try {
    const sqlParams = [params.userId, params.playerId]
    const sql = `SELECT * FROM inventory.get_player_gear_inventory($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerGearInventory[]
  } catch (error) {
    console.error("Error fetching getPlayerGearInventory:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getPlayerGearInventory")
  }
}
