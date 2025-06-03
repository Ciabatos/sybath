"use server"

import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { TPlayerMovmentAction } from "@/methods/actions/mapTiles/playerMovmentAction"

export type TMovmentActionTaskInProcess = {
  scheduled_at: Date | null
  method_parameters: TPlayerMovmentAction
}

export async function getMovmentActionInProcess(playerId: number) {
  if (!playerId || isNaN(playerId)) {
    return null
  }

  try {
    const result = await query(`SELECT * FROM map.movment_action_in_process($1);`, [playerId])

    return result.rows as TMovmentActionTaskInProcess[]
  } catch (error) {
    console.error("Error fetching getMovmentActionInProcess:", error)
    throw new Error("Failed to fetch getMovmentActionInProcess")
  }
}
