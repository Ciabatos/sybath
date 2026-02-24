// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TActivePlayerSquadParams = {
  playerId: number
}

export type TActivePlayerSquad = {
  squadId: number
}

export type TActivePlayerSquadRecordBySquadId = Record<string, TActivePlayerSquad>

export async function getActivePlayerSquad(params: TActivePlayerSquadParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM squad.get_active_player_squad($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TActivePlayerSquad[]
  } catch (error) {
    console.error("Error fetching getActivePlayerSquad:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getActivePlayerSquad")
  }
}
