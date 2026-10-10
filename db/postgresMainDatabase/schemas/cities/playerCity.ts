// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerCityParams = {
  userId: string
  playerId: number
}

export type TPlayerCityClientParams = Omit<TPlayerCityParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TPlayerCityFetchParams = Partial<TPlayerCityClientParams>

export type TPlayerCity = {
  cityId: number
}

export type TPlayerCityRecordByCityId = Record<string, TPlayerCity>

export async function getPlayerCity(params: TPlayerCityParams) {
  try {
    const sqlParams = [params.userId, params.playerId]
    const sql = `SELECT * FROM cities.get_player_city($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerCity[]
  } catch (error) {
    console.error("Error fetching getPlayerCity:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getPlayerCity")
  }
}
