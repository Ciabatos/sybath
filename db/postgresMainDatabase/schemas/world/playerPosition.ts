// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerPositionParams = {
  userId: string
  mapId: number
  playerId: number
}

export type TPlayerPositionClientParams = Omit<TPlayerPositionParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TPlayerPositionFetchParams = Partial<TPlayerPositionClientParams>

export type TPlayerPosition = {
  x: number
  y: number
  imageMap: string
  inSquad: boolean
}

export type TPlayerPositionRecordByXY = Record<string, TPlayerPosition>

export async function getPlayerPosition(params: TPlayerPositionParams) {
  try {
    const sqlParams = [params.userId, params.mapId, params.playerId]
    const sql = `SELECT * FROM world.get_player_position($1, $2, $3);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerPosition[]
  } catch (error) {
    console.error("Error fetching getPlayerPosition:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getPlayerPosition")
  }
}
