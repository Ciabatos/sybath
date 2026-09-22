// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelKeys } from "@/methods/functions/util/snakeToCamel"


export type TDoAddItemToPlayerInventoryParams = {
  userId: string
  playerId: number
  itemId: number
  quantity: number
}

export type TDoAddItemToPlayerInventory = {
  status: boolean
  message: string
}

export async function doAddItemToPlayerInventory(params: TDoAddItemToPlayerInventoryParams) {
  try {
    const sqlParams = [
      params.userId
      ,
      params.playerId
      ,
      params.itemId
      ,
      params.quantity
      
    ]
    const sql = `SELECT * FROM inventory.do_add_item_to_player_inventory($1, $2, $3, $4);`
    const result = await query(sql, sqlParams)


    return snakeToCamelKeys(result.rows[0]) as TDoAddItemToPlayerInventory
  } catch (error) {
    console.error("Error executing doAddItemToPlayerInventory:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })
    
    throw new Error("Failed to execute doAddItemToPlayerInventory")
  }
}