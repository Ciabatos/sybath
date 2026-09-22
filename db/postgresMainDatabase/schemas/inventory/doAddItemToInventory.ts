// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelKeys } from "@/methods/functions/util/snakeToCamel"


export type TDoAddItemToInventoryParams = {
  userId: string
  inventoryContainerId: number
  itemId: number
  quantity: number
}

export type TDoAddItemToInventory = {
  status: boolean
  message: string
}

export async function doAddItemToInventory(params: TDoAddItemToInventoryParams) {
  try {
    const sqlParams = [
      params.userId
      ,
      params.inventoryContainerId
      ,
      params.itemId
      ,
      params.quantity
      
    ]
    const sql = `SELECT * FROM inventory.do_add_item_to_inventory($1, $2, $3, $4);`
    const result = await query(sql, sqlParams)


    return snakeToCamelKeys(result.rows[0]) as TDoAddItemToInventory
  } catch (error) {
    console.error("Error executing doAddItemToInventory:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })
    
    throw new Error("Failed to execute doAddItemToInventory")
  }
}