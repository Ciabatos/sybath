"use client"

import { TInventorySlot } from "@/components/inventory/InventorySlot"
import {
  useFetchPlayerInventory,
  usePlayerInventoryState,
} from "@/methods/hooks/inventory/core/useFetchPlayerInventory"
import { useFetchItemsItems, useItemsItemsState } from "@/methods/hooks/items/core/useFetchItemsItems"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function usePlayerInventory() {
  const { playerId } = usePlayerId()

  useFetchItemsItems()
  const items = useItemsItemsState()

  useFetchPlayerInventory({ playerId })
  const playerInventory = usePlayerInventoryState()

  const combinedPlayerInventory = Object.values(playerInventory).map(
    (playerInventory): TInventorySlot => ({
      type: "playerInventory",
      ...playerInventory,
      ...items[playerInventory.itemId],
    }),
  )

  return { combinedPlayerInventory }
}
