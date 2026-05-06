import { useFetchItemsItems, useItemsItemsState } from "@/methods/hooks/items/core/useFetchItemsItems"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import {
  useFetchKnownMapTilesResourcesOnMap,
  useKnownMapTilesResourcesOnMapState,
} from "@/methods/hooks/world/core/useFetchKnownMapTilesResourcesOnMap"

export type TCombinedResourcesOnMap = Record<
  string,
  {
    mapTileX: number
    mapTileY: number
    itemIds: {
      itemId: number
      name: string
      description: string
      image: string
    }[]
  }
>

export function useResourcesLayer() {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()

  useFetchKnownMapTilesResourcesOnMap({ mapId, playerId })
  const knownMapTilesResourcesOnMap = useKnownMapTilesResourcesOnMapState()

  useFetchItemsItems()
  const items = useItemsItemsState()

  const combinedResourcesOnMap: TCombinedResourcesOnMap = Object.fromEntries(
    Object.entries(knownMapTilesResourcesOnMap).map(([key, tile]) => [
      key,
      {
        mapTileX: tile.mapTileX,
        mapTileY: tile.mapTileY,
        itemIds: tile.itemIds.map((itemId) => ({
          itemId: itemId.itemId,
          name: items[`${itemId.itemId}`]?.name,
          description: items[`${itemId.itemId}`]?.description,
          image: items[`${itemId.itemId}`]?.image,
        })),
      },
    ]),
  )

  return { combinedResourcesOnMap }
}
