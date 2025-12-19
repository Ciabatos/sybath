// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TWorldMapsParams = {
  id: number
}

export type TWorldMaps = {
  id: number
  name: string
}

export type TWorldMapsRecordById = Record<string, TWorldMaps>

export async function getWorldMaps() {
  try {
    const sql = `SELECT * FROM world.get_maps();`
    
    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TWorldMaps[]
  } catch (error) {
    console.error("Error fetching getWorldMaps:", error)
    throw new Error("Failed to fetch getWorldMaps")
  }
}

export async function getWorldMapsByKey(params: TWorldMapsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_maps_by_key($1);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TWorldMaps[]
  } catch (error) {
    console.error("Error fetching getWorldMapsByKey:", error)
    throw new Error("Failed to fetch getWorldMapsByKey")
  }
}