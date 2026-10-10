// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TAllSkillsParams = {
  userId: string
  playerId: number
}

export type TAllSkillsClientParams = Omit<TAllSkillsParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TAllSkillsFetchParams = Partial<TAllSkillsClientParams>

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
    const sqlParams = [params.userId, params.playerId]
    const sql = `SELECT * FROM attributes.get_all_skills($1, $2);`

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
