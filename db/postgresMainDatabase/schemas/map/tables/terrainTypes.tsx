"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TMapTerrainTypes = {
  id: number
  name: string
  terrain_move_cost: number
  image_url: string
}

export type TMapTerrainTypesById = Record<number, TMapTerrainTypes>

export async function getMapTerrainTypes() {
  try {
    const result = await query("SELECT * FROM map.terrain_types")
    return result.rows as TMapTerrainTypes[]
  } catch (error) {
    console.error("Error fetching getMapTerrainTypes:", error)
    throw new Error("Failed to fetch getMapTerrainTypes")
  }
}
