"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TCityBuildings = {
  id: number
  city_id: number
  city_tile_x: number
  city_tile_y: number
  name: string
  type_name: string
  image_url: string
}

export type TCityBuildingsMapCoordinates = Record<string, TCityBuildings>

export async function getCityBuildings(cityId: number) {
  if (!cityId || isNaN(cityId)) {
    return []
  }
  try {
    const result = await query("SELECT * FROM map.v_buildings WHERE city_id = $1", [cityId])
    return result.rows as TCityBuildings[]
  } catch (error) {
    console.error("Error fetching getCityBuildings:", error)
    throw new Error("Failed to fetch getCityBuildings")
  }
}
