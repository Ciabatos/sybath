"use server"

import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TPlayerVisibleMapData = {
  map_tile_x: number
  map_tile_y: number
  player_id: number
  player_name: string
  player_image_url: string
}

export type TPlayerVisibleMapDataByCoordinates = Record<string, TPlayerVisibleMapData>

export async function getPlayerVisibleMapData(playerId: number) {
  if (!playerId || isNaN(playerId)) {
    return null
  }

  try {
    const result = await query(`SELECT * FROM map.player_visible_map_data($1)`, [playerId])

    return result.rows as TPlayerVisibleMapData[]
  } catch (error) {
    console.error("Error fetching getPlayerVisibleMapData:", error)
    throw new Error("Failed to fetch getPlayerVisibleMapData")
  }
}
