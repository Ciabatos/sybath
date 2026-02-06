// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TWorldLandscapeTypesParams = {
  id: number
}

export type TWorldLandscapeTypes = {
  id: number
  name: string
  moveCost: number
  imageUrl?: string
}

export type TWorldLandscapeTypesRecordById = Record<string, TWorldLandscapeTypes>

export async function getWorldLandscapeTypes() {
  try {
    const sql = `SELECT * FROM world.get_landscape_types();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TWorldLandscapeTypes[]
  } catch (error) {
    console.error("Error fetching getWorldLandscapeTypes:", {
      error,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getWorldLandscapeTypes")
  }
}

export async function getWorldLandscapeTypesByKey(params: TWorldLandscapeTypesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_landscape_types_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TWorldLandscapeTypes[]
  } catch (error) {
    console.error("Error fetching getWorldLandscapeTypesByKey:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getWorldLandscapeTypesByKey")
  }
}
