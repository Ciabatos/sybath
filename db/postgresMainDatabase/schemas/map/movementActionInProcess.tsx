"use server"

import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { TPlayerMovementAction } from "@/methods/actions/mapTiles/playerMovementAction"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TMovementActionTaskInProcess = {
  scheduled_at: Date | null
  method_parameters: TPlayerMovementAction
}

export async function getMovementActionInProcess(playerId: number) {
  if (!playerId || isNaN(playerId)) {
    return null
  }

  try {
    const result = await query(`SELECT * FROM map.movement_action_in_process($1);`, [playerId])

    return snakeToCamelRows(result.rows) as TMovementActionTaskInProcess[]
  } catch (error) {
    console.error("Error fetching getMovementActionInProcess:", error)
    throw new Error("Failed to fetch getMovementActionInProcess")
  }
}
