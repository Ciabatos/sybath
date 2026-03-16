"use client"

import { TInventorySlot } from "@/components/inventory/InventorySlot"
import {
  useFetchOtherPlayerGearInventory,
  useOtherPlayerGearInventoryState,
} from "@/methods/hooks/inventory/core/useFetchOtherPlayerGearInventory"
import { useFetchItemsItems, useItemsItemsState } from "@/methods/hooks/items/core/useFetchItemsItems"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function useOtherPlayerGearInventory() {
  const { playerId } = usePlayerId()
  const otherPlayerId = useOtherPlayerId()

  useFetchItemsItems()
  const items = useItemsItemsState()

  useFetchOtherPlayerGearInventory({ playerId, otherPlayerId })
  const otherPlayerGearInventory = useOtherPlayerGearInventoryState()

  const combinedOtherPlayerGearInventory = Object.values(otherPlayerGearInventory).map(
    (playerGearInventory): TInventorySlot => ({
      type: "otherPlayerGearInventory",
      ...playerGearInventory,
      ...items[playerGearInventory.itemId],
    }),
  )

  return { combinedOtherPlayerGearInventory }
}
