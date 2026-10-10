// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TOtherPlayerProfileParams = {
  userId: string
  playerId: number
  otherPlayerId: string
}

export type TOtherPlayerProfileClientParams = Omit<TOtherPlayerProfileParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TOtherPlayerProfileFetchParams = Partial<TOtherPlayerProfileClientParams>

export type TOtherPlayerProfile = {
  name: string
  secondName: string
  nickname: string
  imagePortrait: string
}

export type TOtherPlayerProfileRecordByName = Record<string, TOtherPlayerProfile>

export async function getOtherPlayerProfile(params: TOtherPlayerProfileParams) {
  try {
    const sqlParams = [params.userId, params.playerId, params.otherPlayerId]
    const sql = `SELECT * FROM players.get_other_player_profile($1, $2, $3);`

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
