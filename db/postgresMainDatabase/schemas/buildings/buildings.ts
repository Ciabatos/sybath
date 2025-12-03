// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TBuildingsBuildingsParams = {
  id: number
}

export type TBuildingsBuildings = {
  id: number
  cityId: number
  cityTileX: number
  cityTileY: number
  buildingTypeId: number
  name: string
}

export type TBuildingsBuildingsRecordByCityTileXCityTileY = Record<string, TBuildingsBuildings>

export async function getBuildingsBuildings() {
  try {
    const sql = `SELECT * FROM buildings.get_buildings();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TBuildingsBuildings[]
  } catch (error) {
    console.error("Error fetching getBuildingsBuildings:", error)
    throw new Error("Failed to fetch getBuildingsBuildings")
  }
}

export async function getBuildingsBuildingsByKey(params: TBuildingsBuildingsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM buildings.get_buildings_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TBuildingsBuildings[]
  } catch (error) {
    console.error("Error fetching getBuildingsBuildingsByKey:", error)
    throw new Error("Failed to fetch getBuildingsBuildingsByKey")
  }
}
