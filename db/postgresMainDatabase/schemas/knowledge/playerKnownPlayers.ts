// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerKnownPlayersParams = {
  playerId: number
}

export type TPlayerKnownPlayers = {
  otherPlayerId: string
  name: string
  secondName: string
  nickname: string
  imagePortrait: string
  mapId: number
  x: number
  y: number
  imageMap: string
}

export type TPlayerKnownPlayersRecordByOtherPlayerId = Record<string, TPlayerKnownPlayers>

export async function getPlayerKnownPlayers(params: TPlayerKnownPlayersParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM knowledge.get_player_known_players($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerKnownPlayers[]
  } catch (error) {
    console.error("Error fetching getPlayerKnownPlayers:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getPlayerKnownPlayers")
  }
}
