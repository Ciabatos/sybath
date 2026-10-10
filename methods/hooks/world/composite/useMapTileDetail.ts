import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import { useFetchItemsItems, useItemsItemsState } from "@/methods/hooks/items/core/useFetchItemsItems"
import {
  useFetchKnownMapTilesResourcesOnTile,
  useKnownMapTilesResourcesOnTileState,
} from "@/methods/hooks/world/core/useFetchKnownMapTilesResourcesOnTile"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMemo } from "react"

export type TMapTileResource = {
  mapTilesResourceId: number
  itemId: number
  quantity: number
  id: number
  name?: string
  description?: string
  image: string
}

/**
 * Zasoby leżące na kafelku, połączone z przedmiotami (nazwa, ikona, opis).
 *
 * Kafelek przyjmuje jako argument zamiast czytać z atomu, dzięki czemu hook nie
 * musi nic sprawdzać i wszystkie `useFetch*` wołają bezwarunkowo. Wcześniejsza
 * wersja robiła `if (!clickedMapTile) return` PRZED fetchami, przez co liczba
 * hooków skakała między 2 a 4 przy każdym kliknięciu — React ostrzega, że
 * kolejność hooków nie może się zmieniać.
 *
 * Wołaj tylko z komponentu renderowanego dla konkretnego kafelka
 * (`MapTileDetailPanel` w `components/map`).
 */
export function useMapTileDetail(tile: TMapTile) {
  const { playerId } = usePlayerId()
  const { mapTiles } = tile

  useFetchKnownMapTilesResourcesOnTile({
    mapId: mapTiles.mapId,
    mapTileX: mapTiles.x,
    mapTileY: mapTiles.y,
    playerId,
  })
  const knownMapTilesResourcesOnTile = useKnownMapTilesResourcesOnTileState()

  useFetchItemsItems()
  const items = useItemsItemsState()

  const combinedKnownMapTilesResourcesOnTile = useMemo(
    () =>
      Object.values(knownMapTilesResourcesOnTile).map((resource) => ({
        ...items[resource.itemId],
        ...resource,
      })),
    [knownMapTilesResourcesOnTile, items],
  )

  return { combinedKnownMapTilesResourcesOnTile }
}
