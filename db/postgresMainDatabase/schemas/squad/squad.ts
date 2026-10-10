// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TSquadParams = {
  userId: string
  playerId: number
}

export type TSquadClientParams = Omit<TSquadParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TSquadFetchParams = Partial<TSquadClientParams>

export type TSquad = {
  squadId: number
  squadName: string
  squadImagePortrait: string
}

export type TSquadRecordBySquadId = Record<string, TSquad>

export async function getSquad(params: TSquadParams) {
  try {
    const sqlParams = [params.userId, params.playerId]
    const sql = `SELECT * FROM squad.get_squad($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TSquad[]
  } catch (error) {
    console.error("Error fetching getSquad:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getSquad")
  }
}
