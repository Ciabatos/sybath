"use client"

import { useFetchOtherPlayerInventory } from "@/methods/hooks/inventory/core/useFetchOtherPlayerInventory"
import { useFetchItemsItems } from "@/methods/hooks/items/core/useFetchItemsItems"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { itemsAtom, otherPlayerInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useOtherPlayerInventory() {
  const { playerId } = usePlayerId()
  const otherPlayerMaskId = useOtherPlayerId()

  useFetchItemsItems()
  const items = useAtomValue(itemsAtom)

  useFetchOtherPlayerInventory({ playerId, otherPlayerMaskId })
  const otherPlayerInventory = useAtomValue(otherPlayerInventoryAtom)

  const combinedOtherPlayerInventory = Object.values(otherPlayerInventory).map((otherPlayerInventory) => ({
    ...otherPlayerInventory,
    ...items[otherPlayerInventory.itemId],
  }))

  return { combinedOtherPlayerInventory }
}
