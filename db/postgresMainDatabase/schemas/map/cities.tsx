"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TCities = {
  id: number
  map_tile_x: number
  map_tile_y: number
  name: string
  move_cost: number
  image_url: string
}

export type TCitiesByCoordinates = Record<string, TCities>

export async function getMapCities() {
  try {
    const result = await query("SELECT * FROM map.cities")
    return result.rows as TCities[]
  } catch (error) {
    console.error("Error fetching getMapCities:", error)
    throw new Error("Failed to fetch getMapCities")
  }
}
