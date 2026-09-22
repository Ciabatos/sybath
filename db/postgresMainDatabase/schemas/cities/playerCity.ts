// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerCityParams = {
  userId: string
  playerId: number
}

export type TPlayerCityClientParams = Omit<TPlayerCityParams, "userId">


export type TPlayerCity = {
  cityId: number
}

export type TPlayerCityRecordByCityId = Record<string, TPlayerCity>

export async function getPlayerCity(params: TPlayerCityParams) {
  try {
    const sqlParams = Object.values(params)
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