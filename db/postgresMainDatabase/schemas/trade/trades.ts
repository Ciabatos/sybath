// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TTradesParams = {
  playerId: number
}

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
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM trade.get_trades($1);`

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
