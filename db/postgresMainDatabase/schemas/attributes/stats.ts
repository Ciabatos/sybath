// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TAttributesStatsParams = {
  id: number
}

export type TAttributesStats = {
  id: number
  name?: string
}

export type TAttributesStatsRecordById = Record<string, TAttributesStats>

export async function getAttributesStats() {
  try {
    const sql = `SELECT * FROM attributes.get_stats();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TAttributesStats[]
  } catch (error) {
    console.error("Error fetching getAttributesStats:", error)
    throw new Error("Failed to fetch getAttributesStats")
  }
}

export async function getAttributesStatsByKey(params: TAttributesStatsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM attributes.get_stats_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TAttributesStats[]
  } catch (error) {
    console.error("Error fetching getAttributesStatsByKey:", error)
    throw new Error("Failed to fetch getAttributesStatsByKey")
  }
}
