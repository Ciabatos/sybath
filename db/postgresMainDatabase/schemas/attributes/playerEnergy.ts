// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerEnergyParams = {
  userId: string
  playerId: number
}

export type TPlayerEnergyClientParams = Omit<TPlayerEnergyParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TPlayerEnergyFetchParams = Partial<TPlayerEnergyClientParams>

export type TPlayerEnergy = {
  currentEnergy: number
  maxEnergy: number
  lastRegeneratedAt: string
}

export type TPlayerEnergyRecordByLastRegeneratedAt = Record<string, TPlayerEnergy>

export async function getPlayerEnergy(params: TPlayerEnergyParams) {
  try {
    const sqlParams = [params.userId, params.playerId]
    const sql = `SELECT * FROM attributes.get_player_energy($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerEnergy[]
  } catch (error) {
    console.error("Error fetching getPlayerEnergy:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getPlayerEnergy")
  }
}
