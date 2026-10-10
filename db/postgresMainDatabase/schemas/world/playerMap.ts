// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerMapParams = {
  userId: string
  playerId: number
}

export type TPlayerMapClientParams = Omit<TPlayerMapParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TPlayerMapFetchParams = Partial<TPlayerMapClientParams>

export type TPlayerMap = {
  mapId: number
}

export type TPlayerMapRecordByMapId = Record<string, TPlayerMap>

export async function getPlayerMap(params: TPlayerMapParams) {
  try {
    const sqlParams = [params.userId, params.playerId]
    const sql = `SELECT * FROM world.get_player_map($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerMap[]
  } catch (error) {
    console.error("Error fetching getPlayerMap:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getPlayerMap")
  }
}
