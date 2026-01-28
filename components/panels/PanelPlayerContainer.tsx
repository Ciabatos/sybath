"use client"

import { InventorySlot } from "@/components/panels/InventorySlot"
import { usePlayerInventory } from "@/methods/hooks/inventory/composite/usePlayerInventory"
import { useDragDropMonitor } from "@dnd-kit/react"
import { toast } from "sonner"
import styles from "./styles/PanelPlayerContainer.module.css"

export function PanelPlayerContainer() {
  const { combinedPlayerInventory, moveOrSwapItem } = usePlayerInventory()

  useDragDropMonitor({
    onDragEnd: async (event) => {
      const { operation, canceled } = event

      if (canceled) return
      if (!operation.target) return

      const source = operation.source
      const target = operation.target

      const sourceData = source?.data
      const targetData = target?.data

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

  const handleSortInventory = () => {
    console.log("Sorting inventory...")
  }

  return (
    <div className={styles.container}>
      <div className={styles.toolbar}>
        <button
          className={styles.sortButton}
          onClick={handleSortInventory}
          title='Sortuj przedmioty'
        >
          🔄 Sortuj
        </button>
        <span className={styles.stats}>
          Przedmioty: {combinedPlayerInventory.filter((item) => item.itemId).length}/{combinedPlayerInventory.length}
        </span>
      </div>

      <div className={styles.grid}>
        {combinedPlayerInventory.map((playerInventory) => (
          <InventorySlot
            key={playerInventory.slotId}
            playerInventory={playerInventory}
          />
        ))}
      </div>
    </div>
  )
}
