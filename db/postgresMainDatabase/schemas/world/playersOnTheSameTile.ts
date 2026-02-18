// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayersOnTheSameTileParams = {
  mapId: number
  playerId: number
}

export type TPlayersOnTheSameTile = {
  otherPlayerId: number
  name: string
  secondName: string
  nickname: string
  imageMap: string
  imagePortrait: string
}

export type TPlayersOnTheSameTileRecordByOtherPlayerId = Record<string, TPlayersOnTheSameTile>

export async function getPlayersOnTheSameTile(params: TPlayersOnTheSameTileParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_players_on_the_same_tile($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayersOnTheSameTile[]
  } catch (error) {
    console.error("Error fetching getPlayersOnTheSameTile:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getPlayersOnTheSameTile")
  }
}
