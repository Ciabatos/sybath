"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TCityTiles = {
  city_id: number
  x: number
  y: number
  terrain_type_id: number
  landscape_type_id?: number
}

export async function getCityTiles(cityId: number) {
  if (!cityId || isNaN(cityId)) {
    return []
  }

  try {
    const result = await query("SELECT * FROM map.city_tiles WHERE city_id = $1", [cityId])
    return result.rows as TCityTiles[]
  } catch (error) {
    console.error("Error fetching getCityTilesTCityTiles:", error)
    throw new Error("Failed to fetch getCityTilesTCityTiles")
  }
}
