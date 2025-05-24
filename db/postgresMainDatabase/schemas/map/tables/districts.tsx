"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TDistricts = {
  id: number
  map_tile_x: number
  map_tile_y: number
  name: string
  owner: number
  type_name: string
  move_cost: number
  image_url: string
}

export type TDistrictsByMapCoordinates = Record<string, TDistricts>

export async function getMapDistricts() {
  try {
    const result = await query("SELECT * FROM map.v_districts")
    return result.rows as TDistricts[]
  } catch (error) {
    console.error("Error fetching getMapDistricts:", error)
    throw new Error("Failed to fetch getMapDistricts")
  }
}
