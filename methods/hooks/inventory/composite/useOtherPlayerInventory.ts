"use client"

import { TInventorySlot } from "@/components/inventory/InventorySlot"
import {
  useFetchOtherPlayerInventory,
  useOtherPlayerInventoryState,
} from "@/methods/hooks/inventory/core/useFetchOtherPlayerInventory"
import { useFetchItemsItems, useItemsItemsState } from "@/methods/hooks/items/core/useFetchItemsItems"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function useOtherPlayerInventory() {
  const { playerId } = usePlayerId()
  const otherPlayerId = useOtherPlayerId()

  useFetchItemsItems()
  const items = useItemsItemsState()

  useFetchOtherPlayerInventory({ playerId, otherPlayerId })
  const otherPlayerInventory = useOtherPlayerInventoryState()

  const combinedOtherPlayerInventory = Object.values(otherPlayerInventory).map(
    (otherPlayerInventory): TInventorySlot => ({
      type: "otherPlayerInventory",
      ...otherPlayerInventory,
      ...items[otherPlayerInventory.itemId],
    }),
  )

  return { combinedOtherPlayerInventory }
}
