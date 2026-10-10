// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TKnownMapTilesResourcesOnMapParams = {
  userId: string
  mapId: number
  playerId: number
}

export type TKnownMapTilesResourcesOnMapClientParams = Omit<TKnownMapTilesResourcesOnMapParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TKnownMapTilesResourcesOnMapFetchParams = Partial<TKnownMapTilesResourcesOnMapClientParams>

export type TCtItemIds = {
  itemId: number
}

export type TKnownMapTilesResourcesOnMap = {
  mapTileX: number
  mapTileY: number
  itemIds: TCtItemIds[]
}

export type TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY = Record<string, TKnownMapTilesResourcesOnMap>

export async function getKnownMapTilesResourcesOnMap(params: TKnownMapTilesResourcesOnMapParams) {
  try {
    const sqlParams = [params.userId, params.mapId, params.playerId]
    const sql = `SELECT * FROM world.get_known_map_tiles_resources_on_map($1, $2, $3);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TKnownMapTilesResourcesOnMap[]
  } catch (error) {
    console.error("Error fetching getKnownMapTilesResourcesOnMap:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getKnownMapTilesResourcesOnMap")
  }
}
