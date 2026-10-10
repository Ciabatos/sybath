// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TAllAbilitiesParams = {
  userId: string
  playerId: number
}

export type TAllAbilitiesClientParams = Omit<TAllAbilitiesParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TAllAbilitiesFetchParams = Partial<TAllAbilitiesClientParams>

export type TAllAbilities = {
  id: number
  name: string
  description: string
  image: string
  value: number
}

export type TAllAbilitiesRecordById = Record<string, TAllAbilities>

export async function getAllAbilities(params: TAllAbilitiesParams) {
  try {
    const sqlParams = [params.userId, params.playerId]
    const sql = `SELECT * FROM attributes.get_all_abilities($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TAllAbilities[]
  } catch (error) {
    console.error("Error fetching getAllAbilities:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getAllAbilities")
  }
}
