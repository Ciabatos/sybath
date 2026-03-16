"use client"

import { TInventorySlot } from "@/components/inventory/InventorySlot"
import {
  useFetchPlayerGearInventory,
  usePlayerGearInventoryState,
} from "@/methods/hooks/inventory/core/useFetchPlayerGearInventory"
import { useFetchItemsItems, useItemsItemsState } from "@/methods/hooks/items/core/useFetchItemsItems"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function usePlayerGearInventory() {
  const { playerId } = usePlayerId()

  useFetchItemsItems()
  const items = useItemsItemsState()

  useFetchPlayerGearInventory({ playerId })
  const playerGearInventory = usePlayerGearInventoryState()

  const combinedPlayerGearInventory = Object.values(playerGearInventory).map(
    (playerGearInventory): TInventorySlot => ({
      type: "playerGearInventory",
      ...playerGearInventory,
      ...items[playerGearInventory.itemId],
    }),
  )

  return { combinedPlayerGearInventory }
}
