// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TAttributesStatsParams = {
  id: number
}

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TAttributesStatsParamsFetchParams = Partial<TAttributesStatsParams>

export type TAttributesStats = {
  id: number
  name: string
  description: string
  image: string
}

export type TAttributesStatsRecordById = Record<string, TAttributesStats>

export async function getAttributesStats() {
  try {
    const sql = `SELECT * FROM attributes.get_stats();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TAttributesStats[]
  } catch (error) {
    console.error("Error fetching getAttributesStats:", {
      error,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getAttributesStats")
  }
}

export async function getAttributesStatsByKey(params: TAttributesStatsParams) {
  try {
    const sqlParams = [params.id]
    const sql = `SELECT * FROM attributes.get_stats_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TAttributesStats[]
  } catch (error) {
    console.error("Error fetching getAttributesStatsByKey:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getAttributesStatsByKey")
  }
}
