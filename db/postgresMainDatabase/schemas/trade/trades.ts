// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TTradesParams = {
  userId: string
  playerId: number
}

export type TTradesClientParams = Omit<TTradesParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TTradesFetchParams = Partial<TTradesClientParams>

export type TTrades = {
  id: number
  status: number
  createdAt: string
  updatedAt: string
  expiresAt: string
}

export type TTradesRecordById = Record<string, TTrades>

export async function getTrades(params: TTradesParams) {
  try {
    const sqlParams = [params.userId, params.playerId]
    const sql = `SELECT * FROM trade.get_trades($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TTrades[]
  } catch (error) {
    console.error("Error fetching getTrades:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getTrades")
  }
}
