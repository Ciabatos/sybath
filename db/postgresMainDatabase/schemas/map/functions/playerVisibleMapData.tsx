"use server"

import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TPlayerVisibleMapData = {
  map_tile_id: number
  player_id: number
  player_name: string
  player_image_url: string
}

export type TPlayerVisibleMapDataById = Record<number, TPlayerVisibleMapData>

export const getPlayersVisibleMapData = async () => {
  try {
    const result = await query(`SELECT * FROM map.all_player_visible_map_data()`)

    return result.rows as TPlayerVisibleMapData[]
  } catch (error) {
    console.error("Error fetching getMapsTilesPlayersPositions:", error)
    throw new Error("Failed to fetch getMapsTilesPlayersPositions")
  }
}

export const getPlayerVisibleMapData = async (playerId: number | undefined) => {
  if (!playerId || isNaN(playerId)) {
    return null
  }

  try {
    const result = await query(`SELECT * FROM map.player_visible_map_data($1)`, [playerId])

    return result.rows as TPlayerVisibleMapData[]
  } catch (error) {
    console.error("Error fetching getMapsFieldsPlayerPosition:", error)
    throw new Error("Failed to fetch getMapsFieldsPlayerPosition")
  }
}
