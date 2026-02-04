"use client"

import { TInventorySlot } from "@/components/panels/InventorySlot"
import { doMoveOrSwapItemAction } from "@/methods/actions/inventory/doMoveOrSwapItemAction"
import { useMutatePlayerInventory } from "@/methods/hooks/inventory/core/useMutatePlayerInventory"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useDragDropMonitor } from "@dnd-kit/react"
import { toast } from "sonner"

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

export function useInventory() {
  const { playerId } = usePlayerId()
  const { mutatePlayerInventory } = useMutatePlayerInventory({ playerId })

  useDragDropMonitor({
    onDragEnd: async (event) => {
      const { operation, canceled } = event

      if (canceled) return
      if (!operation.target) return

      const source = operation.source
      const target = operation.target

      const sourceData = source?.data as TInventorySlot
      const targetData = target?.data as TInventorySlot

      if (!sourceData?.itemId) return

      const result = await moveOrSwapItem({
        fromSlotId: sourceData.slotId,
        toSlotId: targetData.slotId,
        fromInventoryContainerId: sourceData.containerId,
        toInventoryContainerId: targetData.containerId,
        fromItemId: sourceData.itemId,
        toItemId: targetData.itemId,
        fromName: sourceData.name,
        toName: targetData.name,
        fromQuantity: sourceData.quantity,
        toQuantity: targetData.quantity,
      })

      toast.success(result)
    },
  })

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
      console.error("Unexpected error in moveOrSwapItem:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  const handleSortInventory = () => {
    console.log("Sorting inventory...")
  }

  return { moveOrSwapItem, handleSortInventory, useDragDropMonitor }
}
