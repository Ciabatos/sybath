"use client"

import { useFetchPlayerInventory } from "@/methods/hooks/inventory/core/useFetchPlayerInventory"
import { useFetchItemsItems } from "@/methods/hooks/items/core/useFetchItemsItems"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { itemsAtom, playerInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function usePlayerInventory() {
  const { playerId } = usePlayerId()

  useFetchItemsItems()
  const items = useAtomValue(itemsAtom)

  useFetchPlayerInventory({ playerId })
  const playerInventory = useAtomValue(playerInventoryAtom)

  const combinedPlayerInventory = Object.entries(playerInventory).map(([key, playerInventory]) => ({
    ...playerInventory,
    ...items[playerInventory.itemId],
  }))

  return { items, playerInventory, combinedPlayerInventory }
}
