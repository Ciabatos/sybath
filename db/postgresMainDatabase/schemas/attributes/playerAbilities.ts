// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerAbilitiesParams = {
  userId: string
  playerId: number
}

export type TPlayerAbilitiesClientParams = Omit<TPlayerAbilitiesParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TPlayerAbilitiesFetchParams = Partial<TPlayerAbilitiesClientParams>

export type TPlayerAbilities = {
  abilityId: number
  value: number
  name: string
}

export type TPlayerAbilitiesRecordByAbilityId = Record<string, TPlayerAbilities>

export async function getPlayerAbilities(params: TPlayerAbilitiesParams) {
  try {
    const sqlParams = [params.userId, params.playerId]
    const sql = `SELECT * FROM attributes.get_player_abilities($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerAbilities[]
  } catch (error) {
    console.error("Error fetching getPlayerAbilities:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getPlayerAbilities")
  }
}
