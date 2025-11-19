// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TMapDistrictsParams = {
  id: number
}

export type TMapDistricts = {
  id: number
  mapTileX: number
  mapTileY: number
  districtTypeId: number
  name?: string
}

export type TMapDistrictsRecordByMapTileXMapTileY = Record<string, TMapDistricts>

export async function getMapDistricts() {
  try {
    const sql = `SELECT * FROM map.get_districts();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TMapDistricts[]
  } catch (error) {
    console.error("Error fetching getMapDistricts:", error)
    throw new Error("Failed to fetch getMapDistricts")
  }
}

export async function getMapDistrictsByKey(params: TMapDistrictsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM map.get_districts_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TMapDistricts[]
  } catch (error) {
    console.error("Error fetching getMapDistrictsByKey:", error)
    throw new Error("Failed to fetch getMapDistrictsByKey")
  }
}
