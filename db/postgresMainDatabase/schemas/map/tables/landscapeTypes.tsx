"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TMapLandscapeTypes = {
  landscape_type_id: number
  name: string
  landscape_move_cost: number
  image_url: string
}

export const getMapLandscapeTypes = async () => {
  try {
    const result = await query("SELECT * FROM map.landscape_types")
    return result.rows as TMapLandscapeTypes[]
  } catch (error) {
    console.error("Error fetching getMapLandscapeTypes:", error)
    throw new Error("Failed to fetch getMapLandscapeTypes")
  }
}
