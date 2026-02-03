"use client"

import { doMoveOrSwapItemAction } from "@/methods/actions/inventory/doMoveOrSwapItemAction"
import { useFetchPlayerGearInventory } from "@/methods/hooks/inventory/core/useFetchPlayerGearInventory"
import { useMutatePlayerGearInventory } from "@/methods/hooks/inventory/core/useMutatePlayerGearInventory"
import { useFetchItemsItems } from "@/methods/hooks/items/core/useFetchItemsItems"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { itemsAtom, playerGearInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

type TMoveOrSwapItem = {
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

export function usePlayerGearInventory() {
  const { playerId } = usePlayerId()
  const { mutatePlayerGearInventory } = useMutatePlayerGearInventory({ playerId })

  useFetchItemsItems()
  const items = useAtomValue(itemsAtom)

  useFetchPlayerGearInventory({ playerId })
  const playerGearInventory = useAtomValue(playerGearInventoryAtom)

  const combinedPlayerGearInventory = Object.values(playerGearInventory).map((playerGearInventory) => ({
    ...playerGearInventory,
    ...items[playerGearInventory.itemId],
  }))

  async function moveOrSwapItem(params: TMoveOrSwapItem) {
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

      mutatePlayerGearInventory([
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
      console.error("Unexpected error in moveOrSwapItem:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  return { combinedPlayerGearInventory, moveOrSwapItem }
}
