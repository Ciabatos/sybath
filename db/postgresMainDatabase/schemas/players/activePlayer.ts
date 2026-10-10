// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TActivePlayerParams = {
  userId: string
}

export type TActivePlayerClientParams = Omit<TActivePlayerParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TActivePlayerFetchParams = Partial<TActivePlayerClientParams>

export type TActivePlayer = {
  id: number
}

export type TActivePlayerRecordById = Record<string, TActivePlayer>

export async function getActivePlayer(params: TActivePlayerParams) {
  try {
    const sqlParams = [params.userId]
    const sql = `SELECT * FROM players.get_active_player($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TActivePlayer[]
  } catch (error) {
    console.error("Error fetching getActivePlayer:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getActivePlayer")
  }
}
