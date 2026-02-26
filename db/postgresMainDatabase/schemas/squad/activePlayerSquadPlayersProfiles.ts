// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TActivePlayerSquadPlayersProfilesParams = {
  playerId: number
}

export type TActivePlayerSquadPlayersProfiles = {
  otherPlayerId: number
  name: string
  secondName: string
  nickname: string
  imageMap: string
  imagePortrait: string
}

export type TActivePlayerSquadPlayersProfilesRecordByOtherPlayerId = Record<string, TActivePlayerSquadPlayersProfiles>

export async function getActivePlayerSquadPlayersProfiles(params: TActivePlayerSquadPlayersProfilesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM squad.get_active_player_squad_players_profiles($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TActivePlayerSquadPlayersProfiles[]
  } catch (error) {
    console.error("Error fetching getActivePlayerSquadPlayersProfiles:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getActivePlayerSquadPlayersProfiles")
  }
}
