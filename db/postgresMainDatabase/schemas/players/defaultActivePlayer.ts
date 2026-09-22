// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TDefaultActivePlayerParams = {
  userId: string
}

export type TDefaultActivePlayerClientParams = Omit<TDefaultActivePlayerParams, "userId">

export type TDefaultActivePlayer = {
  id: number
}

export type TDefaultActivePlayerRecordById = Record<string, TDefaultActivePlayer>

export async function getDefaultActivePlayer(params: TDefaultActivePlayerParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM players.get_default_active_player($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TDefaultActivePlayer[]
  } catch (error) {
    console.error("Error fetching getDefaultActivePlayer:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getDefaultActivePlayer")
  }
}
