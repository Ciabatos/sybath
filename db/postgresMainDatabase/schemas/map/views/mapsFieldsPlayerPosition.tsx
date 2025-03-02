"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { auth } from "@/auth"

export type TMapsFieldsPlayerPosition = {
  player_name: string
  player_image_url: string
  map_field_id: number
}

export const getMapsFieldsPlayerPosition = async () => {
  const session = await auth()
  const playerName: string = session?.user?.name ?? ""

  try {
    const result = await query(`SELECT player_name, player_image_url, map_field_id FROM map.maps_fields_player_position WHERE player_name = $1`, [playerName])

    return result.rows as TMapsFieldsPlayerPosition[]
  } catch (error) {
    console.error("Error fetching getMapsFieldsPlayerPosition:", error)
    throw new Error("Failed to fetch getMapsFieldsPlayerPosition")
  }
}
