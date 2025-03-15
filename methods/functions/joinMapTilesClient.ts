"use client"
import { TMapLandscapeTypes } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { TMapsFieldsPlayerPosition } from "@/db/postgresMainDatabase/schemas/map/views/mapTilesPlayerPosition"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import { produce } from "immer"

export function joinMapTilesClient(
  oldTiles: Record<string, TjoinedMapTile>,
  newTiles: TMapTiles[],
  terrainTypes: Record<number, TMapTerrainTypes>,
  landscapeTypes: Record<number, TMapLandscapeTypes>,
  mapTilesPlayerPostion: Record<string, TMapsFieldsPlayerPosition> | undefined,
): Record<string, TjoinedMapTile> {
  console.log(oldTiles, "landscapeTypes")
  return produce(oldTiles, (draft) => {
    newTiles.forEach((newTile) => {
      const key = `${newTile.x},${newTile.y}`

      if (draft[key]) {
        draft[key].terrain_type_id = newTile.terrain_type_id

        const terrain = terrainTypes[newTile.terrain_type_id]
        const landscape = newTile.landscape_type_id !== undefined ? landscapeTypes[newTile.landscape_type_id] : undefined

        draft[key].terrain_name = terrain?.name
        draft[key].terrain_move_cost = terrain?.terrain_move_cost + (landscape?.landscape_move_cost ?? 0)
        draft[key].terrain_image_url = terrain?.image_url

        draft[key].landscape_name = landscape?.name
        draft[key].landscape_image_url = landscape?.image_url

        const player = mapTilesPlayerPostion?.[newTile.id]
        draft[key].player_name = player?.player_name
        draft[key].player_image_url = player?.player_image_url
      }
    })
  })
}
