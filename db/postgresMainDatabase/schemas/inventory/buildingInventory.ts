// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TBuildingInventoryParams = {
  userId: string
  buildingId: number
}

export type TBuildingInventoryClientParams = Omit<TBuildingInventoryParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TBuildingInventoryFetchParams = Partial<TBuildingInventoryClientParams>

export type TBuildingInventory = {
  slotId: number
  containerId: number
  inventoryContainerTypeId: number
  inventorySlotTypeId: number
  itemId: number
  name: string
  quantity: number
}

export type TBuildingInventoryRecordBySlotId = Record<string, TBuildingInventory>

export async function getBuildingInventory(params: TBuildingInventoryParams) {
  try {
    const sqlParams = [params.userId, params.buildingId]
    const sql = `SELECT * FROM inventory.get_building_inventory($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TBuildingInventory[]
  } catch (error) {
    console.error("Error fetching getBuildingInventory:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getBuildingInventory")
  }
}
