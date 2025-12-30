// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TWorldTerrainTypesParams = {
  id: number
}

export type TWorldTerrainTypes = {
  id: number
  name: string
  moveCost: number
  imageUrl?: string
}

export type TWorldTerrainTypesRecordById = Record<string, TWorldTerrainTypes>

export async function getWorldTerrainTypes() {
  try {
    const sql = `SELECT * FROM world.get_terrain_types();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TWorldTerrainTypes[]
  } catch (error) {
    console.error("Error fetching getWorldTerrainTypes:", error)
    throw new Error("Failed to fetch getWorldTerrainTypes")
  }
}

export async function getWorldTerrainTypesByKey(params: TWorldTerrainTypesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_terrain_types_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TWorldTerrainTypes[]
  } catch (error) {
    console.error("Error fetching getWorldTerrainTypesByKey:", error)
    throw new Error("Failed to fetch getWorldTerrainTypesByKey")
  }
}
