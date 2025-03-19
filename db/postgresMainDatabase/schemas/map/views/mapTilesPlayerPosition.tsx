"use server"

import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TMapsFieldsPlayerPosition = {
  player_name: string
  player_image_url: string
  map_field_id: number
}

export const getMapsTilesPlayerPosition = async (userId: number | undefined) => {
  if (!userId || isNaN(userId)) {
    return null
  }

  try {
    const result = await query(`SELECT player_name, player_image_url, map_field_id FROM map.v_map_tiles_player_position WHERE user_Id = $1`, [userId])

    return result.rows as TMapsFieldsPlayerPosition[]
  } catch (error) {
    console.error("Error fetching getMapsFieldsPlayerPosition:", error)
    throw new Error("Failed to fetch getMapsFieldsPlayerPosition")
  }
}

export const getMapsTilesPlayersPositions = async () => {
  try {
    const result = await query(`SELECT player_name, player_image_url, map_field_id FROM map.v_map_tiles_player_position`)

    return result.rows as TMapsFieldsPlayerPosition[]
  } catch (error) {
    console.error("Error fetching getMapsTilesPlayersPositions:", error)
    throw new Error("Failed to fetch getMapsTilesPlayersPositions")
  }
}
