// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TSquadPlayersProfilesParams = {
  playerId: number
}

export type TSquadPlayersProfiles = {
  otherPlayerId: string
  name: string
  secondName: string
  nickname: string
  imageMap: string
  imagePortrait: string
}

export type TSquadPlayersProfilesRecordByOtherPlayerId = Record<string, TSquadPlayersProfiles>

export async function getSquadPlayersProfiles(params: TSquadPlayersProfilesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM squad.get_squad_players_profiles($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TSquadPlayersProfiles[]
  } catch (error) {
    console.error("Error fetching getSquadPlayersProfiles:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getSquadPlayersProfiles")
  }
}
