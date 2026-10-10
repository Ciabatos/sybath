// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TDistrictsDistrictsParams = {
  mapId: number
}

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TDistrictsDistrictsParamsFetchParams = Partial<TDistrictsDistrictsParams>

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
    console.error("Error fetching getDistrictsDistricts:", {
      error,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getDistrictsDistricts")
  }
}

export async function getDistrictsDistrictsByKey(params: TDistrictsDistrictsParams) {
  try {
    const sqlParams = [params.mapId]
    const sql = `SELECT * FROM districts.get_districts_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TDistrictsDistricts[]
  } catch (error) {
    console.error("Error fetching getDistrictsDistrictsByKey:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getDistrictsDistrictsByKey")
  }
}
