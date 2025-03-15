"use client"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import { TMapsFieldsPlayerPosition } from "@/db/postgresMainDatabase/schemas/map/views/mapsFieldsPlayerPosition"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import { produce } from "immer"

export function joinMapTilesClient(
  oldTiles: Record<string, TjoinedMapTile>,
  newTiles: TMapTiles[],
  terrainTypes: Record<number, TMapTerrainTypes>,
  mapTilesPlayerPostion: Record<string, TMapsFieldsPlayerPosition> | undefined,
): Record<string, TjoinedMapTile> {
  return produce(oldTiles, (draft) => {
    newTiles.forEach((newTile) => {
      const key = `${newTile.x},${newTile.y}`

      if (draft[key]) {
        draft[key].terrain_type_id = newTile.terrain_type_id

        const terrain = terrainTypes[newTile.terrain_type_id]
        draft[key].terrain_name = terrain?.name
        draft[key].terrain_move_cost = terrain?.terrain_move_cost
        draft[key].image_url = terrain?.image_url

        const player = mapTilesPlayerPostion?.[newTile.id]
        draft[key].player_name = player?.player_name
        draft[key].player_image_url = player?.player_image_url
      }
    })
  })
}
