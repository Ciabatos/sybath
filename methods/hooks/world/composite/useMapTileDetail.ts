import { useFetchItemsItems } from "@/methods/hooks/items/core/useFetchItemsItems"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { useFetchKnownMapTilesResourcesOnTile } from "@/methods/hooks/world/core/useFetchKnownMapTilesResourcesOnTile"
import { itemsAtom, knownMapTilesResourcesOnTileAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

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
  const knownMapTilesResourcesOnTile = useAtomValue(knownMapTilesResourcesOnTileAtom)

  useFetchItemsItems()
  const items = useAtomValue(itemsAtom)

  const combinedKnownMapTilesResourcesOnTile = Object.values(knownMapTilesResourcesOnTile).map(
    (knownMapTilesResourcesOnTile) => ({
      ...items[knownMapTilesResourcesOnTile.itemId],
      ...knownMapTilesResourcesOnTile,
    }),
  )

  return { combinedKnownMapTilesResourcesOnTile }
}
