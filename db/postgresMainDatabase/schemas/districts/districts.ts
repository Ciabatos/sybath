// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TDistrictsDistrictsParams = {
  mapId: number
}

export type TDistrictsDistricts = {
  id: number
  mapId: number
  mapTileX: number
  mapTileY: number
  districtTypeId: number
  name?: string
}

export type TDistrictsDistrictsRecordByMapTileXMapTileY = Record<string, TDistrictsDistricts>

export async function getDistrictsDistricts() {
  try {
    const sql = `SELECT * FROM districts.get_districts();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TDistrictsDistricts[]
  } catch (error) {
    console.error("Error fetching getDistrictsDistricts:", error)
    throw new Error("Failed to fetch getDistrictsDistricts")
  }
}

export async function getDistrictsDistrictsByKey(params: TDistrictsDistrictsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM districts.get_districts_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TDistrictsDistricts[]
  } catch (error) {
    console.error("Error fetching getDistrictsDistrictsByKey:", error)
    throw new Error("Failed to fetch getDistrictsDistrictsByKey")
  }
}
