"use client"

import { TInventorySlot } from "@/components/inventory/InventorySlot"
import { doMoveOrSwapItemAction } from "@/methods/actions/inventory/doMoveOrSwapItemAction"
import { useMutateOtherPlayerGearInventory } from "@/methods/hooks/inventory/core/useMutateOtherPlayerGearInventory"
import { useMutateOtherPlayerInventory } from "@/methods/hooks/inventory/core/useMutateOtherPlayerInventory"
import { useMutatePlayerGearInventory } from "@/methods/hooks/inventory/core/useMutatePlayerGearInventory"
import { useMutatePlayerInventory } from "@/methods/hooks/inventory/core/useMutatePlayerInventory"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useDragDropMonitor } from "@dnd-kit/react"
import { toast } from "sonner"

type TInventoryType = "playerInventory" | "playerGearInventory" | "otherPlayerInventory" | "otherPlayerGearInventory"

type TMoveOrSwapItem = {
  fromType: TInventoryType
  toType: TInventoryType
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

type TInventoryUpdate = {
  type: TInventoryType
  slotId: number
  containerId: number
  inventoryContainerTypeId: number
  inventorySlotTypeId: number
  itemId: number
  name: string
  quantity: number
}

// containerTypeId → mutator key
const CONTAINER_TYPE_TO_MUTATOR = {
  1: "inventory",
  2: "gearInventory",
} as const

export function useInventoryMonitor() {
  const { playerId } = usePlayerId()
  const otherPlayerId = useOtherPlayerId()
  const { mutatePlayerInventory } = useMutatePlayerInventory({ playerId })
  const { mutatePlayerGearInventory } = useMutatePlayerGearInventory({ playerId })
  const { mutateOtherPlayerInventory } = useMutateOtherPlayerInventory({ playerId, otherPlayerId: otherPlayerId })
  const { mutateOtherPlayerGearInventory } = useMutateOtherPlayerGearInventory({
    playerId,
    otherPlayerId,
  })

  const mutators: Record<TInventoryType, (updates: TInventoryUpdate[]) => void> = {
    playerInventory: mutatePlayerInventory,
    playerGearInventory: mutatePlayerGearInventory,
    otherPlayerInventory: mutateOtherPlayerInventory,
    otherPlayerGearInventory: mutateOtherPlayerGearInventory,
  }

  useDragDropMonitor({
    onDragEnd: async (event) => {
      const { operation, canceled } = event
      if (canceled || !operation.target) return

      const sourceData = operation.source?.data as TInventorySlot
      const targetData = operation.target?.data as TInventorySlot
      if (!sourceData?.itemId) return

      const result = await moveOrSwapItem({
        fromType: sourceData.type,
        toType: targetData.type,
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
        playerId,
        fromSlotId: params.fromSlotId,
        toSlotId: params.toSlotId,
        fromInventoryContainerId: params.fromInventoryContainerId,
        toInventoryContainerId: params.toInventoryContainerId,
      })

      if (!result.status) return result.message

      // Po swapie: slot "from" otrzymuje przedmiot z "to" i odwrotnie
      const sides = [
        {
          type: params.fromType,
          slotId: params.fromSlotId,
          containerId: params.fromInventoryContainerId,
          inventoryContainerTypeId: params.fromInventoryContainerTypeId,
          inventorySlotTypeId: params.fromInventorySlotTypeId,
          itemId: params.toItemId,
          name: params.toName,
          quantity: params.toQuantity,
        },
        {
          type: params.toType,
          slotId: params.toSlotId,
          containerId: params.toInventoryContainerId,
          inventoryContainerTypeId: params.toInventoryContainerTypeId,
          inventorySlotTypeId: params.toInventorySlotTypeId,
          itemId: params.fromItemId,
          name: params.fromName,
          quantity: params.fromQuantity,
        },
      ]

      // Grupujemy po type i wywołujemy właściwy mutator
      const grouped = Object.groupBy(sides, (s) => s.type) as Partial<Record<TInventoryType, TInventoryUpdate[]>>

      for (const [type, updates] of Object.entries(grouped) as [TInventoryType, TInventoryUpdate[]][]) {
        mutators[type]?.(updates)
      }

      return result.message
    } catch (err) {
      console.error("Unexpected error in moveOrSwapItem:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }
}
