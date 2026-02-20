// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TOtherPlayerProfileParams = {
  playerId: number
  otherPlayerMaskId: string
}

export type TOtherPlayerProfile = {
  name: string
  secondName: string
  nickname: string
  imageMap: string
  imagePortrait: string
}

export type TOtherPlayerProfileRecordByName = Record<string, TOtherPlayerProfile>

export async function getOtherPlayerProfile(params: TOtherPlayerProfileParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM players.get_other_player_profile($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TOtherPlayerProfile[]
  } catch (error) {
    console.error("Error fetching getOtherPlayerProfile:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getOtherPlayerProfile")
  }
}
