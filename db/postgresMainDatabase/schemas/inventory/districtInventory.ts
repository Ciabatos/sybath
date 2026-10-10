// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TDistrictInventoryParams = {
  userId: string
  districtId: number
}

export type TDistrictInventoryClientParams = Omit<TDistrictInventoryParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TDistrictInventoryFetchParams = Partial<TDistrictInventoryClientParams>

export type TDistrictInventory = {
  slotId: number
  containerId: number
  inventoryContainerTypeId: number
  inventorySlotTypeId: number
  itemId: number
  name: string
  quantity: number
}

export type TDistrictInventoryRecordBySlotId = Record<string, TDistrictInventory>

export async function getDistrictInventory(params: TDistrictInventoryParams) {
  try {
    const sqlParams = [params.userId, params.districtId]
    const sql = `SELECT * FROM inventory.get_district_inventory($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TDistrictInventory[]
  } catch (error) {
    console.error("Error fetching getDistrictInventory:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getDistrictInventory")
  }
}
