// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TAllSkillsParams = {
  playerId: number
}

export type TAllSkills = {
  id: number
  name: string
  description: string
  image: string
  value: number
}

export type TAllSkillsRecordById = Record<string, TAllSkills>

export async function getAllSkills(params: TAllSkillsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM attributes.get_all_skills($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TAllSkills[]
  } catch (error) {
    console.error("Error fetching getAllSkills:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getAllSkills")
  }
}
