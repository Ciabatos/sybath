"use client"

import { doMoveOrSwapItemAction } from "@/methods/actions/inventory/doMoveOrSwapItemAction"
import { useFetchPlayerInventory } from "@/methods/hooks/inventory/core/useFetchPlayerInventory"
import { useMutatePlayerInventory } from "@/methods/hooks/inventory/core/useMutatePlayerInventory"
import { useFetchItemsItems } from "@/methods/hooks/items/core/useFetchItemsItems"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { itemsAtom, playerInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

type TmoveOrSwapItem = {
  fromSlotId: number
  toSlotId: number
  fromInventoryContainerId: number
  toInventoryContainerId: number
  fromItemId: number
  toItemId: number
  fromName: string
  toName: string
  fromQuantity: number
  toQuantity: number
}

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

  async function moveOrSwapItem(params: TmoveOrSwapItem) {
    try {
      const result = await doMoveOrSwapItemAction({
        playerId: playerId,
        fromSlotId: params.fromSlotId,
        toSlotId: params.toSlotId,
        fromInventoryContainerId: params.fromInventoryContainerId,
        toInventoryContainerId: params.toInventoryContainerId,
      })

      console.log(result)
      if (!result.status) {
        return result.message
      }

      mutatePlayerInventory([
        {
          slotId: params.fromSlotId,
          containerId: params.fromInventoryContainerId,
          itemId: params.toItemId,
          name: params.toName,
          quantity: params.toQuantity,
        },
        {
          slotId: params.toSlotId,
          containerId: params.toInventoryContainerId,
          itemId: params.fromItemId,
          name: params.fromName,
          quantity: params.fromQuantity,
        },
      ])

      return result.message
    } catch (err) {
      console.error("Unexpected error in switchPlayer:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  return { combinedPlayerInventory, moveOrSwapItem }
}
