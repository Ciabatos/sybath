// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TKnownPlayersPositionsParams = {
  userId: string
  mapId: number
  playerId: number
}

export type TKnownPlayersPositionsClientParams = Omit<TKnownPlayersPositionsParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TKnownPlayersPositionsFetchParams = Partial<TKnownPlayersPositionsClientParams>

export type TCtOtherPlayers = {
  otherPlayerId: string
  imageMap: string
  inSquad: boolean
  squadId: number
}

export type TKnownPlayersPositions = {
  x: number
  y: number
  otherPlayers: TCtOtherPlayers[]
}

export type TKnownPlayersPositionsRecordByXY = Record<string, TKnownPlayersPositions>

export async function getKnownPlayersPositions(params: TKnownPlayersPositionsParams) {
  try {
    const sqlParams = [params.userId, params.mapId, params.playerId]
    const sql = `SELECT * FROM world.get_known_players_positions($1, $2, $3);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TKnownPlayersPositions[]
  } catch (error) {
    console.error("Error fetching getKnownPlayersPositions:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getKnownPlayersPositions")
  }
}
