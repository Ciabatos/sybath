// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TAttributesSkillsParams = {
  id: number
}

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TAttributesSkillsParamsFetchParams = Partial<TAttributesSkillsParams>

export type TAttributesSkills = {
  id: number
  name: string
  description: string
  image: string
}

export type TAttributesSkillsRecordById = Record<string, TAttributesSkills>

export async function getAttributesSkills() {
  try {
    const sql = `SELECT * FROM attributes.get_skills();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TAttributesSkills[]
  } catch (error) {
    console.error("Error fetching getAttributesSkills:", {
      error,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getAttributesSkills")
  }
}

export async function getAttributesSkillsByKey(params: TAttributesSkillsParams) {
  try {
    const sqlParams = [params.id]
    const sql = `SELECT * FROM attributes.get_skills_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TAttributesSkills[]
  } catch (error) {
    console.error("Error fetching getAttributesSkillsByKey:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getAttributesSkillsByKey")
  }
}
