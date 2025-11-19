// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TMapLandscapeTypesParams = {
  id: number
}

export type TMapLandscapeTypes = {
  id: number
  name: string
  moveCost: number
  imageUrl?: string
}

export type TMapLandscapeTypesRecordById = Record<number, TMapLandscapeTypes>

export async function getMapLandscapeTypes() {
  try {
    const sql = `SELECT * FROM map.get_landscape_types();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TMapLandscapeTypes[]
  } catch (error) {
    console.error("Error fetching getMapLandscapeTypes:", error)
    throw new Error("Failed to fetch getMapLandscapeTypes")
  }
}

export async function getMapLandscapeTypesByKey(params: TMapLandscapeTypesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM map.get_landscape_types_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TMapLandscapeTypes[]
  } catch (error) {
    console.error("Error fetching getMapLandscapeTypesByKey:", error)
    throw new Error("Failed to fetch getMapLandscapeTypesByKey")
  }
}
