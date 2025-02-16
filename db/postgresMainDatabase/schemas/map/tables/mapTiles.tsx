"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

interface TMapTiles {
  id: number
  map_id: number
  x: number
  y: number
  terrain_type_id: number
}

export const getMapTiles = async () => {
  try {
    const result = await query("SELECT * FROM map.maps_fields")
    return result.rows as TMapTiles[]
  } catch (error) {
    console.error("Error fetching getMapTiles:", error)
    throw new Error("Failed to fetch getMapTiles")
  }
}
