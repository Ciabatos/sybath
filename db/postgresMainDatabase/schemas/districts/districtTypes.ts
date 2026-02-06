// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TDistrictsDistrictTypesParams = {
  id: number
}

export type TDistrictsDistrictTypes = {
  id: number
  name: string
  moveCost: number
  imageUrl?: string
}

export type TDistrictsDistrictTypesRecordById = Record<string, TDistrictsDistrictTypes>

export async function getDistrictsDistrictTypes() {
  try {
    const sql = `SELECT * FROM districts.get_district_types();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TDistrictsDistrictTypes[]
  } catch (error) {
    console.error("Error fetching getDistrictsDistrictTypes:", {
      error,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getDistrictsDistrictTypes")
  }
}

export async function getDistrictsDistrictTypesByKey(params: TDistrictsDistrictTypesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM districts.get_district_types_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TDistrictsDistrictTypes[]
  } catch (error) {
    console.error("Error fetching getDistrictsDistrictTypesByKey:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getDistrictsDistrictTypesByKey")
  }
}
