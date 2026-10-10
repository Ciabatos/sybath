// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TCitiesCityTilesParams = {
  cityId: number
}

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TCitiesCityTilesParamsFetchParams = Partial<TCitiesCityTilesParams>

export type TCitiesCityTiles = {
  cityId: number
  x: number
  y: number
  terrainTypeId: number
  landscapeTypeId?: number
}

export type TCitiesCityTilesRecordByXY = Record<string, TCitiesCityTiles>

export async function getCitiesCityTiles() {
  try {
    const sql = `SELECT * FROM cities.get_city_tiles();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TCitiesCityTiles[]
  } catch (error) {
    console.error("Error fetching getCitiesCityTiles:", {
      error,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getCitiesCityTiles")
  }
}

export async function getCitiesCityTilesByKey(params: TCitiesCityTilesParams) {
  try {
    const sqlParams = [params.cityId]
    const sql = `SELECT * FROM cities.get_city_tiles_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TCitiesCityTiles[]
  } catch (error) {
    console.error("Error fetching getCitiesCityTilesByKey:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getCitiesCityTilesByKey")
  }
}
