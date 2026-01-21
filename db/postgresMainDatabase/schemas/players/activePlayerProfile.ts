// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TActivePlayerProfileParams = {
  playerId: number
}

export type TActivePlayerProfile = {
  name: string
  imageMap: string
  imagePortrait: string
}

export type TActivePlayerProfileRecordByName = Record<string, TActivePlayerProfile>

export async function getActivePlayerProfile(params: TActivePlayerProfileParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM players.get_active_player_profile($1);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TActivePlayerProfile[]
  } catch (error) {
    console.error("Error fetching getActivePlayerProfile:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })
    
    throw new Error("Failed to fetch getActivePlayerProfile")
  }
}