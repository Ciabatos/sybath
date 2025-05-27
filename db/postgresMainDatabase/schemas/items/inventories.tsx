"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TInventorySlots = {
  row: number
  col: number
  inventory_container_id: number
  item_id: number | null
  name: string | null
  quantity: number | null
}

export async function getPlayerInventorySlots(playerId: number) {
  if (!playerId || isNaN(playerId)) {
    return null
  }

  try {
    const result = await query(`SELECT * FROM items.player_inventory($1)`, [playerId])
    return result.rows as TInventorySlots[]
  } catch (error) {
    console.error("Error fetching getPlayerInventorySlots:", error)
    throw new Error("Failed to fetch getPlayerInventorySlots")
  }
}

export async function getOtherPlayerInventorySlots(playerId: number, otherPlayerId: number) {
  if (!playerId || isNaN(playerId)) {
    return null
  }

  try {
    const result = await query(`SELECT * FROM items.other_player_inventory($1 , $2)`, [playerId, otherPlayerId])
    return result.rows as TInventorySlots[]
  } catch (error) {
    console.error("Error fetching getOtherPlayerInventorySlots:", error)
    throw new Error("Failed to fetch getOtherPlayerInventorySlots")
  }
}

export async function getBuildingInventorySlots(playerId: number, buildingId: number) {
  if (!playerId || isNaN(playerId)) {
    return null
  }

  try {
    const result = await query(`SELECT * FROM items.building_inventory($1 , $2)`, [playerId, buildingId])
    return result.rows as TInventorySlots[]
  } catch (error) {
    console.error("Error fetching getBuildingInventorySlots:", error)
    throw new Error("Failed to fetch getBuildingInventorySlots")
  }
}

export async function getDistrictInventorySlots(playerId: number, districtId: number) {
  if (!playerId || isNaN(playerId)) {
    return null
  }

  try {
    const result = await query(`SELECT * FROM items.district_inventory($1 , $2)`, [playerId, districtId])
    return result.rows as TInventorySlots[]
  } catch (error) {
    console.error("Error fetching getDistrictInventorySlots:", error)
    throw new Error("Failed to fetch getDistrictInventorySlots")
  }
}
