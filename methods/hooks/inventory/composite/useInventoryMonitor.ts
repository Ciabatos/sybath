"use client"

import { TInventorySlot } from "@/components/panels/InventorySlot"
import { doMoveOrSwapItemAction } from "@/methods/actions/inventory/doMoveOrSwapItemAction"
import { useMutatePlayerGearInventory } from "@/methods/hooks/inventory/core/useMutatePlayerGearInventory"
import { useMutatePlayerInventory } from "@/methods/hooks/inventory/core/useMutatePlayerInventory"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useDragDropMonitor } from "@dnd-kit/react"
import { toast } from "sonner"

type TMoveOrSwapItem = {
  fromSlotId: number
  toSlotId: number
  fromInventoryContainerId: number
  toInventoryContainerId: number
  fromInventoryContainerTypeId: number
  toInventoryContainerTypeId: number
  fromInventorySlotTypeId: number
  toInventorySlotTypeId: number
  fromItemId: number
  toItemId: number
  fromName: string
  toName: string
  fromQuantity: number
  toQuantity: number
}

export function useInventoryMonitor() {
  const { playerId } = usePlayerId()
  const { mutatePlayerInventory } = useMutatePlayerInventory({ playerId })
  const { mutatePlayerGearInventory } = useMutatePlayerGearInventory({ playerId })

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
        fromInventoryContainerTypeId: sourceData.inventoryContainerTypeId,
        toInventoryContainerTypeId: targetData.inventoryContainerTypeId,
        fromInventorySlotTypeId: sourceData.inventorySlotTypeId,
        toInventorySlotTypeId: targetData.inventorySlotTypeId,
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

      if (!result.status) {
        return result.message
      }

      const updatesPlayerInventory = []
      const updatesPlayerGearInventory = []

      if (params.fromInventoryContainerTypeId === 1) {
        updatesPlayerInventory.push({
          slotId: params.fromSlotId,
          containerId: params.fromInventoryContainerId,
          inventoryContainerTypeId: params.fromInventoryContainerTypeId,
          inventorySlotTypeId: params.fromInventorySlotTypeId,
          itemId: params.toItemId,
          name: params.toName,
          quantity: params.toQuantity,
        })
      }
      if (params.toInventoryContainerTypeId === 1) {
        updatesPlayerInventory.push({
          slotId: params.toSlotId,
          containerId: params.toInventoryContainerId,
          inventoryContainerTypeId: params.toInventoryContainerTypeId,
          inventorySlotTypeId: params.toInventorySlotTypeId,
          itemId: params.fromItemId,
          name: params.fromName,
          quantity: params.fromQuantity,
        })
      }

      if (params.fromInventoryContainerTypeId === 2) {
        updatesPlayerGearInventory.push({
          slotId: params.fromSlotId,
          containerId: params.fromInventoryContainerId,
          inventoryContainerTypeId: params.fromInventoryContainerTypeId,
          inventorySlotTypeId: params.fromInventorySlotTypeId,
          itemId: params.toItemId,
          name: params.toName,
          quantity: params.toQuantity,
        })
      }
      if (params.toInventoryContainerTypeId === 2) {
        updatesPlayerGearInventory.push({
          slotId: params.toSlotId,
          containerId: params.toInventoryContainerId,
          inventoryContainerTypeId: params.toInventoryContainerTypeId,
          inventorySlotTypeId: params.toInventorySlotTypeId,
          itemId: params.fromItemId,
          name: params.fromName,
          quantity: params.fromQuantity,
        })
      }
      if (updatesPlayerInventory.length) {
        mutatePlayerInventory(updatesPlayerInventory)
      }

      if (updatesPlayerGearInventory.length) {
        mutatePlayerGearInventory(updatesPlayerGearInventory)
      }

      return result.message
    } catch (err) {
      console.error("Unexpected error in moveOrSwapItem:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }
}
