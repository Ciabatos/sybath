// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TKnownMapTilesParams = {
  userId: string
  mapId: number
  playerId: number
}

export type TKnownMapTilesClientParams = Omit<TKnownMapTilesParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TKnownMapTilesFetchParams = Partial<TKnownMapTilesClientParams>

export type TKnownMapTiles = {
  mapId: number
  x: number
  y: number
  terrainTypeId: number
  landscapeTypeId: number
}

export type TKnownMapTilesRecordByXY = Record<string, TKnownMapTiles>

export async function getKnownMapTiles(params: TKnownMapTilesParams) {
  try {
    const sqlParams = [params.userId, params.mapId, params.playerId]
    const sql = `SELECT * FROM world.get_known_map_tiles($1, $2, $3);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TKnownMapTiles[]
  } catch (error) {
    console.error("Error fetching getKnownMapTiles:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getKnownMapTiles")
  }
}
