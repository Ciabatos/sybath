// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TKnownMapTilesResourcesOnTileParams = {
  userId: string
  mapId: number
  mapTileX: number
  mapTileY: number
  playerId: number
}

export type TKnownMapTilesResourcesOnTileClientParams = Omit<TKnownMapTilesResourcesOnTileParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TKnownMapTilesResourcesOnTileFetchParams = Partial<TKnownMapTilesResourcesOnTileClientParams>

export type TKnownMapTilesResourcesOnTile = {
  mapTilesResourceId: number
  itemId: number
  quantity: number
}

export type TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId = Record<string, TKnownMapTilesResourcesOnTile>

export async function getKnownMapTilesResourcesOnTile(params: TKnownMapTilesResourcesOnTileParams) {
  try {
    const sqlParams = [params.userId, params.mapId, params.mapTileX, params.mapTileY, params.playerId]
    const sql = `SELECT * FROM world.get_known_map_tiles_resources_on_tile($1, $2, $3, $4, $5);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TKnownMapTilesResourcesOnTile[]
  } catch (error) {
    console.error("Error fetching getKnownMapTilesResourcesOnTile:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getKnownMapTilesResourcesOnTile")
  }
}
