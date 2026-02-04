"use client"

import { useFetchPlayerGearInventory } from "@/methods/hooks/inventory/core/useFetchPlayerGearInventory"
import { useFetchItemsItems } from "@/methods/hooks/items/core/useFetchItemsItems"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { itemsAtom, playerGearInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function usePlayerGearInventory() {
  const { playerId } = usePlayerId()

  useFetchItemsItems()
  const items = useAtomValue(itemsAtom)

  useFetchPlayerGearInventory({ playerId })
  const playerGearInventory = useAtomValue(playerGearInventoryAtom)

  const combinedPlayerGearInventory = Object.values(playerGearInventory).map((playerGearInventory) => ({
    ...playerGearInventory,
    ...items[playerGearInventory.itemId],
  }))

  return { combinedPlayerGearInventory }
}
