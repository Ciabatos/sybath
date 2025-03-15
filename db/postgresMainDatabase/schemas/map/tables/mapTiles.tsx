"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TMapTiles = {
  id: number
  map_id: number
  x: number
  y: number
  terrain_type_id: number
  landscape_type_id?: number
}

export const getMapTiles = async () => {
  try {
    const result = await query("SELECT * FROM map.map_tiles")
    return result.rows as TMapTiles[]
  } catch (error) {
    console.error("Error fetching getMapTiles:", error)
    throw new Error("Failed to fetch getMapTiles")
  }
}
