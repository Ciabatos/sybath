"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TMapLandscapeTypes = {
  id: number
  name: string
  move_cost: number
  image_url: string
}

export type TMapLandscapeTypesById = Record<number, TMapLandscapeTypes>

export async function getMapLandscapeTypes() {
  try {
    const result = await query("SELECT * FROM map.landscape_types")
    return result.rows as TMapLandscapeTypes[]
  } catch (error) {
    console.error("Error fetching getMapLandscapeTypes:", error)
    throw new Error("Failed to fetch getMapLandscapeTypes")
  }
}
