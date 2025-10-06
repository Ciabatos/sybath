"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TPlayerVisibleMapDataResult &#x3D; {
  player_id: number
  player_name: any
  player_image_url: any
  map_tile_x: number
  map_tile_y: number
}

export async function PlayerVisibleMapData(p_player_id: number) {
  try {
    const result = await query(
      `
      CALL map.player_visible_map_data(
      );`,
      [p_player_id]
    )

    return result.rows as TPlayerVisibleMapDataResult[]
  } catch (error) {
    console.error("Error executing player_visible_map_data:", error)
    throw new Error("Failed to execute player_visible_map_data")
  }
}
