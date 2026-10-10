// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TOtherSquadPlayersProfilesParams = {
  userId: string
  playerId: number
  squadId: number
}

export type TOtherSquadPlayersProfilesClientParams = Omit<TOtherSquadPlayersProfilesParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TOtherSquadPlayersProfilesFetchParams = Partial<TOtherSquadPlayersProfilesClientParams>

export type TOtherSquadPlayersProfiles = {
  otherPlayerId: string
  name: string
  secondName: string
  nickname: string
  imageMap: string
  imagePortrait: string
}

export type TOtherSquadPlayersProfilesRecordByOtherPlayerId = Record<string, TOtherSquadPlayersProfiles>

export async function getOtherSquadPlayersProfiles(params: TOtherSquadPlayersProfilesParams) {
  try {
    const sqlParams = [params.userId, params.playerId, params.squadId]
    const sql = `SELECT * FROM squad.get_other_squad_players_profiles($1, $2, $3);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TOtherSquadPlayersProfiles[]
  } catch (error) {
    console.error("Error fetching getOtherSquadPlayersProfiles:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getOtherSquadPlayersProfiles")
  }
}
