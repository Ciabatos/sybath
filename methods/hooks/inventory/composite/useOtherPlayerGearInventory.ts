"use client"

import { useFetchOtherPlayerGearInventory } from "@/methods/hooks/inventory/core/useFetchOtherPlayerGearInventory"
import { useFetchItemsItems } from "@/methods/hooks/items/core/useFetchItemsItems"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { itemsAtom, otherPlayerGearInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useOtherPlayerGearInventory() {
  const { playerId } = usePlayerId()
  const otherPlayerMaskId = useOtherPlayerId()

  useFetchItemsItems()
  const items = useAtomValue(itemsAtom)

  useFetchOtherPlayerGearInventory({ playerId, otherPlayerMaskId })
  const otherPlayerGearInventory = useAtomValue(otherPlayerGearInventoryAtom)

  const combinedOtherPlayerGearInventory = Object.values(otherPlayerGearInventory).map((playerGearInventory) => ({
    ...playerGearInventory,
    ...items[playerGearInventory.itemId],
  }))

  return { combinedOtherPlayerGearInventory }
}
