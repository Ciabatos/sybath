"use client"

import { doMoveOrSwapItemAction } from "@/methods/actions/inventory/doMoveOrSwapItemAction"
import { useFetchPlayerInventory } from "@/methods/hooks/inventory/core/useFetchPlayerInventory"
import { useMutatePlayerInventory } from "@/methods/hooks/inventory/core/useMutatePlayerInventory"
import { useFetchItemsItems } from "@/methods/hooks/items/core/useFetchItemsItems"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { itemsAtom, playerInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function usePlayerInventory() {
  const { playerId } = usePlayerId()
  const { mutatePlayerInventory } = useMutatePlayerInventory({ playerId })

  useFetchItemsItems()
  const items = useAtomValue(itemsAtom)

  useFetchPlayerInventory({ playerId })
  const playerInventory = useAtomValue(playerInventoryAtom)

  const combinedPlayerInventory = Object.entries(playerInventory).map(([key, playerInventory]) => ({
    ...playerInventory,
    ...items[playerInventory.itemId],
  }))

  async function moveOrSwapItem(
    fromSlotId: number,
    toSlotId: number,
    fromInventoryContainerId: number,
    toInventoryContainerId: number,
    fromItemId: number,
    toItemId: number,
    fromName: string,
    toName: string,
    fromQuantity: number,
    toQuantity: number,
  ) {
    try {
      const result = await doMoveOrSwapItemAction({
        playerId: playerId,
        fromSlotId: fromSlotId,
        toSlotId: toSlotId,
        fromInventoryContainerId: fromInventoryContainerId,
        toInventoryContainerId: toInventoryContainerId,
      })

      console.log(result)
      if (!result.status) {
        return result.message
      }

      mutatePlayerInventory({
        slotId: fromSlotId,
        containerId: fromInventoryContainerId,
        itemId: fromItemId,
        name: fromName,
        quantity: fromQuantity,
      })
      mutatePlayerInventory({
        slotId: toSlotId,
        containerId: toInventoryContainerId,
        itemId: toItemId,
        name: toName,
        quantity: toQuantity,
      })

      return result.message
    } catch (err) {
      console.error("Unexpected error in switchPlayer:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  return { combinedPlayerInventory, moveOrSwapItem }
}
