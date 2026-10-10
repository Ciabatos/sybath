// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TActivePlayerProfileParams = {
  userId: string
  playerId: number
}

export type TActivePlayerProfileClientParams = Omit<TActivePlayerProfileParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TActivePlayerProfileFetchParams = Partial<TActivePlayerProfileClientParams>

export type TActivePlayerProfile = {
  name: string
  secondName: string
  nickname: string
  imageMap: string
  imagePortrait: string
}

export type TActivePlayerProfileRecordByName = Record<string, TActivePlayerProfile>

export async function getActivePlayerProfile(params: TActivePlayerProfileParams) {
  try {
    const sqlParams = [params.userId, params.playerId]
    const sql = `SELECT * FROM players.get_active_player_profile($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TActivePlayerProfile[]
  } catch (error) {
    console.error("Error fetching getActivePlayerProfile:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getActivePlayerProfile")
  }
}
