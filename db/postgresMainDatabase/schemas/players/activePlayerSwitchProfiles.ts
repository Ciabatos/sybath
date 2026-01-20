// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TActivePlayerSwitchProfilesParams = {
  playerId: number
}

export type TActivePlayerSwitchProfiles = {
  name: string
  imagePortrait: string
}

export type TActivePlayerSwitchProfilesRecordByName = Record<string, TActivePlayerSwitchProfiles>

export async function getActivePlayerSwitchProfiles(params: TActivePlayerSwitchProfilesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM players.get_active_player_switch_profiles($1);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TActivePlayerSwitchProfiles[]
  } catch (error) {
    console.error("Error fetching getActivePlayerSwitchProfiles:", error)
    throw new Error("Failed to fetch getActivePlayerSwitchProfiles")
  }
}