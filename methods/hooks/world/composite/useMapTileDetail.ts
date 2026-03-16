import { useFetchItemsItems, useItemsItemsState } from "@/methods/hooks/items/core/useFetchItemsItems"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import {
  useFetchKnownMapTilesResourcesOnTile,
  useKnownMapTilesResourcesOnTileState,
} from "@/methods/hooks/world/core/useFetchKnownMapTilesResourcesOnTile"

export type TMapTileResource = {
  mapTilesResourceId: number
  itemId: number
  quantity: number
  id: number
  name?: string
  description?: string
  image: string
}

export function useMapTileDetail() {
  const { playerId } = usePlayerId()
  const { clickedMapTile } = useMapTileActions()

  if (!clickedMapTile) {
    return { knownMapTilesResourcesOnTile: null }
  }

  const mapId = clickedMapTile.mapTiles.mapId
  const mapTileX = clickedMapTile.mapTiles.x
  const mapTileY = clickedMapTile.mapTiles.y

  useFetchKnownMapTilesResourcesOnTile({ mapId, mapTileX, mapTileY, playerId })
  const knownMapTilesResourcesOnTile = useKnownMapTilesResourcesOnTileState()

  useFetchItemsItems()
  const items = useItemsItemsState()

  const combinedKnownMapTilesResourcesOnTile = Object.values(knownMapTilesResourcesOnTile).map(
    (knownMapTilesResourcesOnTile) => ({
      ...items[knownMapTilesResourcesOnTile.itemId],
      ...knownMapTilesResourcesOnTile,
    }),
  )

  return { combinedKnownMapTilesResourcesOnTile }
}
