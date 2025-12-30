// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TAttributesSkillsParams = {
  id: number
}

export type TAttributesSkills = {
  id: number
  name?: string
}

export type TAttributesSkillsRecordById = Record<string, TAttributesSkills>

export async function getAttributesSkills() {
  try {
    const sql = `SELECT * FROM attributes.get_skills();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TAttributesSkills[]
  } catch (error) {
    console.error("Error fetching getAttributesSkills:", error)
    throw new Error("Failed to fetch getAttributesSkills")
  }
}

export async function getAttributesSkillsByKey(params: TAttributesSkillsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM attributes.get_skills_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TAttributesSkills[]
  } catch (error) {
    console.error("Error fetching getAttributesSkillsByKey:", error)
    throw new Error("Failed to fetch getAttributesSkillsByKey")
  }
}
