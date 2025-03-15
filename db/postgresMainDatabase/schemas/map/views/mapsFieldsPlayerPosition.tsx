"use server"
import { auth } from "@/auth"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TMapsFieldsPlayerPosition = {
  player_name: string
  player_image_url: string
  map_field_id: number
}

export const getMapsFieldsPlayerPosition = async () => {
  const session = await auth()
  const userId: number = Number(session?.user?.userId) ?? ""

  if (!userId || isNaN(Number(userId))) {
    return null
  }

  try {
    const result = await query(`SELECT player_name, player_image_url, map_field_id FROM map.maps_fields_player_position WHERE userId = $1`, [userId])

    return result.rows as TMapsFieldsPlayerPosition[]
  } catch (error) {
    console.error("Error fetching getMapsFieldsPlayerPosition:", error)
    throw new Error("Failed to fetch getMapsFieldsPlayerPosition")
  }
}
