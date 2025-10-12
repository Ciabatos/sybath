// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetFunction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TPlayerVisibleMapDataResult = {
  player_id: number
  player_name: string
  player_image_url: string
  map_tile_x: number
  map_tile_y: number
}

export async function playerVisibleMapData(p_player_id: number) {
  try {
    const result = await query(
      `SELECT * FROM map.player_visible_map_data($1);`,
      [p_player_id]
    )

    return result.rows as TPlayerVisibleMapDataResult[]
  } catch (error) {
    console.error("Error executing playerVisibleMapData:", error)
    throw new Error("Failed to execute playerVisibleMapData")
  }
}