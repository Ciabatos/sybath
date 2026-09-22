// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TAllAbilitiesParams = {
  userId: string
  playerId: number
}

export type TAllAbilitiesClientParams = Omit<TAllAbilitiesParams, "userId">


export type TAllAbilities = {
  id: number
  name: string
  description: string
  image: string
  value: number
}

export type TAllAbilitiesRecordById = Record<string, TAllAbilities>

export async function getAllAbilities(params: TAllAbilitiesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM attributes.get_all_abilities($1, $2);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TAllAbilities[]
  } catch (error) {
    console.error("Error fetching getAllAbilities:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })
    
    throw new Error("Failed to fetch getAllAbilities")
  }
}