// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TMapTerrainTypesParams = {
  id: number
}

export type TMapTerrainTypes = {
  id: number
  name: string
  moveCost: number
  imageUrl?: string
}

export type TMapTerrainTypesRecordById = Record<number, TMapTerrainTypes>

export async function getMapTerrainTypes() {
  try {
    const sql = `SELECT * FROM map.get_terrain_types();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TMapTerrainTypes[]
  } catch (error) {
    console.error("Error fetching getMapTerrainTypes:", error)
    throw new Error("Failed to fetch getMapTerrainTypes")
  }
}

export async function getMapTerrainTypesByKey(params: TMapTerrainTypesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM map.get_terrain_types_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TMapTerrainTypes[]
  } catch (error) {
    console.error("Error fetching getMapTerrainTypesByKey:", error)
    throw new Error("Failed to fetch getMapTerrainTypesByKey")
  }
}
