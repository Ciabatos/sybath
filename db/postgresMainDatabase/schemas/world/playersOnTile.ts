// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayersOnTileParams = {
  mapId: number
  mapTileX: number
  mapTileY: number
  playerId: number
}

export type TPlayersOnTile = {
  otherPlayerId: string
  name: string
  secondName: string
  nickname: string
  imagePortrait: string
}

export type TPlayersOnTileRecordByOtherPlayerId = Record<string, TPlayersOnTile>

export async function getPlayersOnTile(params: TPlayersOnTileParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_players_on_tile($1, $2, $3, $4);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayersOnTile[]
  } catch (error) {
    console.error("Error fetching getPlayersOnTile:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getPlayersOnTile")
  }
}
