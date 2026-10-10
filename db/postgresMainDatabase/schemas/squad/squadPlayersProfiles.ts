// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TSquadPlayersProfilesParams = {
  userId: string
  playerId: number
}

export type TSquadPlayersProfilesClientParams = Omit<TSquadPlayersProfilesParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TSquadPlayersProfilesFetchParams = Partial<TSquadPlayersProfilesClientParams>

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
    const sqlParams = [params.userId, params.playerId]
    const sql = `SELECT * FROM squad.get_squad_players_profiles($1, $2);`

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
