// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TAttributesAbilitiesParams = {
  id: number
}

export type TAttributesAbilities = {
  id: number
  name?: string
}

export type TAttributesAbilitiesRecordById = Record<number, TAttributesAbilities>

export async function getAttributesAbilities() {
  try {
    const sql = `SELECT * FROM attributes.get_abilities();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TAttributesAbilities[]
  } catch (error) {
    console.error("Error fetching getAttributesAbilities:", error)
    throw new Error("Failed to fetch getAttributesAbilities")
  }
}

export async function getAttributesAbilitiesByKey(params: TAttributesAbilitiesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM attributes.get_abilities_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TAttributesAbilities[]
  } catch (error) {
    console.error("Error fetching getAttributesAbilitiesByKey:", error)
    throw new Error("Failed to fetch getAttributesAbilitiesByKey")
  }
}
