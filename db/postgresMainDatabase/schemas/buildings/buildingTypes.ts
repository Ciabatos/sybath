// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TBuildingsBuildingTypesParams = {
  id: number
}

export type TBuildingsBuildingTypes = {
  id: number
  name: string
  imageUrl?: string
}

export type TBuildingsBuildingTypesRecordById = Record<string, TBuildingsBuildingTypes>

export async function getBuildingsBuildingTypes() {
  try {
    const sql = `SELECT * FROM buildings.get_building_types();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TBuildingsBuildingTypes[]
  } catch (error) {
    console.error("Error fetching getBuildingsBuildingTypes:", {
      error,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getBuildingsBuildingTypes")
  }
}

export async function getBuildingsBuildingTypesByKey(params: TBuildingsBuildingTypesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM buildings.get_building_types_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TBuildingsBuildingTypes[]
  } catch (error) {
    console.error("Error fetching getBuildingsBuildingTypesByKey:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getBuildingsBuildingTypesByKey")
  }
}
