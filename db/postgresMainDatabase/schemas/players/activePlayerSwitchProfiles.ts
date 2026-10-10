// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TActivePlayerSwitchProfilesParams = {
  userId: string
  playerId: number
}

export type TActivePlayerSwitchProfilesClientParams = Omit<TActivePlayerSwitchProfilesParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TActivePlayerSwitchProfilesFetchParams = Partial<TActivePlayerSwitchProfilesClientParams>

export type TActivePlayerSwitchProfiles = {
  id: number
  name: string
  secondName: string
  nickname: string
  imagePortrait: string
}

export type TActivePlayerSwitchProfilesRecordById = Record<string, TActivePlayerSwitchProfiles>

export async function getActivePlayerSwitchProfiles(params: TActivePlayerSwitchProfilesParams) {
  try {
    const sqlParams = [params.userId, params.playerId]
    const sql = `SELECT * FROM players.get_active_player_switch_profiles($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TActivePlayerSwitchProfiles[]
  } catch (error) {
    console.error("Error fetching getActivePlayerSwitchProfiles:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getActivePlayerSwitchProfiles")
  }
}
