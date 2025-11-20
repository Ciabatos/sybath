// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TMapBuildingsParams = {
  id: number
}

export type TMapBuildings = {
  id: number
  cityId: number
  cityTileX: number
  cityTileY: number
  buildingTypeId: number
  name: string
}

export type TMapBuildingsRecordByCityTileXCityTileY = Record<string, TMapBuildings>

export async function getMapBuildings() {
  try {
    const sql = `SELECT * FROM map.get_buildings();`
    
    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TMapBuildings[]
  } catch (error) {
    console.error("Error fetching getMapBuildings:", error)
    throw new Error("Failed to fetch getMapBuildings")
  }
}

export async function getMapBuildingsByKey(params: TMapBuildingsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM map.get_buildings_by_key($1);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TMapBuildings[]
  } catch (error) {
    console.error("Error fetching getMapBuildingsByKey:", error)
    throw new Error("Failed to fetch getMapBuildingsByKey")
  }
}