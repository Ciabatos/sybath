// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TOtherPlayerStatsParams = {
  userId: string
  playerId: number
  otherPlayerId: string
}

export type TOtherPlayerStatsClientParams = Omit<TOtherPlayerStatsParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TOtherPlayerStatsFetchParams = Partial<TOtherPlayerStatsClientParams>

export type TOtherPlayerStats = {
  statId: number
  value: number
  name: string
}

export type TOtherPlayerStatsRecordByStatId = Record<string, TOtherPlayerStats>

export async function getOtherPlayerStats(params: TOtherPlayerStatsParams) {
  try {
    const sqlParams = [params.userId, params.playerId, params.otherPlayerId]
    const sql = `SELECT * FROM attributes.get_other_player_stats($1, $2, $3);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TOtherPlayerStats[]
  } catch (error) {
    console.error("Error fetching getOtherPlayerStats:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getOtherPlayerStats")
  }
}
