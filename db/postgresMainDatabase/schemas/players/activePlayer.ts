// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TActivePlayerParams = {
  playerId: number
}

export type TActivePlayer = {
  id: number
  name: string
  imageMap: string
  imagePortrait: string
}

export type TActivePlayerRecordById = Record<string, TActivePlayer>

export async function getActivePlayer(params: TActivePlayerParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM players.get_active_player($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TActivePlayer[]
  } catch (error) {
    console.error("Error fetching getActivePlayer:", error)
    throw new Error("Failed to fetch getActivePlayer")
  }
}
